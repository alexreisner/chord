require 'httparty'

module Chord

  class << self
    attr_accessor :base_url
    attr_accessor :api_key

    def config(options)
      self.base_url = options[:base_url] if options[:base_url]
      self.api_key = options[:api_key] if options[:api_key]
    end

    def config_from_file(filepath)
      if File.exist?(filepath)
        require 'yaml'
        config = YAML.load(File.read(filepath), symbolize_names: true)
        Chord.config(
          base_url: config[:base_url],
          api_key: config[:api_key]
        )
      else
        false
      end
    end

    def config_from_env
      if ENV['CHORD_BASE_URL'] or ENV['CHORD_API_KEY']
        Chord.config(
          base_url: ENV['CHORD_BASE_URL'],
          api_key: ENV['CHORD_API_KEY']
        )
        true
      else
        false
      end
    end
  end

  class Base
    include HTTParty

    class << self
      attr_writer :per_page
      def per_page; 99999; end

      def all
        check_for_config!
        @all ||= fetch_all_data[base_path].map{ |i| new(i[id_attribute], i) }
      end

      def where(query_options = {})
        check_for_config!
        fetch_all_data(query_options)[base_path].map{ |i| new(i[id_attribute], i) }
      end

      def find(id)
        check_for_config!
        return nil if id.nil? or id == ''
        attrs = fetch_attributes(id)
        attrs.include?('error') ? nil : new(attrs[id_attribute], attrs)
      end

      def base_url
        Chord.base_url
      end

      def http_options
        {headers: {
          'Authorization' => "Bearer #{Chord.api_key}",
          'Content-Type' => 'application/json'
        }}
      end

      private # --------------------------------------------------------------

      def id_attribute
        'id'
      end

      def fetch_attributes(id)
        check_for_config!
        get(base_url + "#{base_path}/#{id}", http_options).parsed_response or raise APIError, 'No data returned by API'
      end

      def fetch_all_data(query_options = {})
        check_for_config!
        query_options = { per_page: per_page }.merge(query_options)
        url = base_url + base_path + '?' + hash_to_query(query_options)
        get(url, http_options).parsed_response or raise APIError, 'No data returned by API'
      end

      def check_for_config!
        if Chord.base_url.nil? or Chord.api_key.nil?
          raise ConfigurationError, 'Please configure Chord by calling Chord.config(base_url: ..., api_key: ...)'
        end
      end

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
      response = self.class.patch(base_url + "#{base_path}/#{id}",
        http_options.merge(body: new_attributes.to_json)
      ).parsed_response
      if response.include?('error')
        raise APIError, "Chord API error (status #{response['status']}): #{response['error']}"
      else
        self.attributes = response
      end
    end

    def delete
      self.class.delete(base_url + "#{base_path}/#{id}", http_options).parsed_response
    end

    # fetch all attributes, but don't overwrite existing ones,
    # in case changes have been made
    def expand!
      self.attributes = self.class.send(:fetch_attributes, id)
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

    def self.base_path
      'users'
    end

    def orders
      Order.where('q[user_id_eq]' => id)
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

    def self.id_attribute
      'number'
    end

    def complete?
      state == 'complete'
    end

    def user
      @user ||= Chord::User.find(attributes['user_id'])
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

    def subscription_installment?
      channel == 'subscriptions'
    end

    def subscription_start?
      expand! unless attributes.include?('subscription_in_cart')
      subscription_in_cart
    end
  end


  class Role < Base

    def self.base_path
      'roles'
    end

    def users
      attributes['users'].map{ |u| Chord::User.new(u['id'], u) }
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

  class Variant < Base

    def self.base_path
      'variants'
    end
  end

  class ConfigurationError < StandardError
  end

  class APIError < StandardError
  end
end
