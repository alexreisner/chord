require 'httparty'

module Chord

  class << self
    attr_writer :env
    def env; @env || :staging; end # :staging by default
  end

  class Base
    include HTTParty

    class << self
      attr_writer :per_page
      def per_page; @per_page || 99999; end

      def all(query_options = {})
        @all ||= fetch_all_data(query_options)[base_path].map{ |i| new(i['id'], i) }
      end

      def find(id)
        attrs = get(base_url + "#{base_path}/#{id}", http_options).parsed_response
        attrs.include?('error') ? nil : new(id, attrs)
      end

      def fetch_all_data(query_options = {})
        query_options = { per_page: per_page }.merge(query_options)
        url = base_url + base_path + '?' + hash_to_query(query_options)
        get(url, http_options).parsed_response
      end

      def base_url
        CHORD_API_CONFIG[Chord.env][:base_url]
      end

      def http_options
        {headers: {
          'Authorization' => "Bearer #{CHORD_API_CONFIG[Chord.env][:api_key]}",
          'Content-Type' => 'application/json'
        }}
      end

      private # --------------------------------------------------------------

      def hash_to_query(hash)
        require 'cgi' unless defined?(CGI) && defined?(CGI.escape)
        hash.collect{ |p|
          p[1].nil? ? nil : p.map{ |i| CGI.escape i.to_s } * '='
        }.compact.sort * '&'
      end
    end

    def base_url
      self.class.base_url
    end

    def base_path
      self.class.base_path
    end

    def http_options
      self.class.http_options
    end

    attr_reader :id
    attr_accessor :attributes

    def initialize(id, attributes = {})
      @id = id
      @attributes = attributes
    end

    def update(new_attributes)
      new_attributes.stringify_keys!
      # merge values into existing metadata
      if new_attributes.include?('metadata')
        # Chord expects all metadata values to be strings
        new_metadata = new_attributes['metadata'].map{ |k,v| [k.to_s, v.to_s] }.to_h
        new_attributes['metadata'] = (attributes['metadata'] || {}).merge(new_metadata)
        # TODO: delete entries with empty value?
      end
      self.attributes = self.class.patch(base_url + "#{base_path}/#{id}",
        http_options.merge(body: new_attributes.to_json)
      ).parsed_response
    end

    def delete
      self.class.delete(base_url + "#{base_path}/#{id}", http_options).parsed_response
    end

    def method_missing(method, *args, &block)
      if attributes.include?(method.to_s)
        attributes[method.to_s]
      else
        super
      end
    end
  end


  class User < Base

    #
    # For avoiding API calls.
    #
    def self.all_by_id
      unless @all_by_id
        @all_by_id = {}
        all.each do |u|
          @all_by_id[u.id] = u
        end
      end
      @all_by_id
    end

    #
    # For mapping users on our old site to Chord.
    #
    def self.all_by_email
      unless @all_by_email
        @all_by_email = {}
        all.each do |u|
          @all_by_email[u.email] = u
        end
      end
      @all_by_email
    end

    def self.base_path
      'users'
    end

    def add_role(role_id)
      self.class.put(base_url + "roles/#{role_id}/add/#{id}", http_options).parsed_response
    end

    def remove_role(role_id)
      self.class.put(base_url + "roles/#{role_id}/remove/#{id}", http_options).parsed_response
    end

    def subscriptions
      self.class.get(base_url + "users/#{id}/subscriptions", http_options).parsed_response['subscriptions'].map{ |s| Chord::Subscription.new(s['id'], s) }
    end

    def find_subscription(subscription_id)
      self.class.get(base_url + "users/#{id}/subscriptions/#{subscription_id}", http_options).parsed_response
    end
  end


  class Order < Base

    def self.base_path
      'orders'
    end

    def user
      Chord::User.find(attributes['user_id'])
    end

    def payments
      self.class.get(base_url + "orders/#{id}/payments", http_options).parsed_response['payments'].map{ |p| Chord::Payment.new(p['id'], p) }
    end

    def create_adjustment(order_id, label, discount)
      attributes = {
        label: label,
        discount_by: discount
      }
      self.class.post(base_url + "hub/orders/#{order_id}/adjustments",
        http_options.merge(body: attributes.to_json)
      ).parsed_response
    end
  end


  class Role < Base

    def self.base_path
      'roles'
    end
  end


  class Subscription < Base

    def user
      u = attributes['user']
      Chord::User.new(u['id'], u)
    end
  end

  class Payment < Base
  end

  class Product < Base

    def self.base_path
      'products'
    end
  end
end
