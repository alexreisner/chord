# Chord Commerce OMS API Gem

These classes provide simple read and write access to the Chord OMS API. Get started like this:

    Chord.config(
      base_url: 'https://<customer>.staging.assembly-api.com/api/',
      api_key: '<key>'
    )

    u = Chord::User.find(1)                   # fetch user by ID
    u.email                                   # view an attribute
    u.attributes                              # see all attributes (returns hash)
    u.update(name: 'Joe Smith', notes: 'Etc') # update attributes
    u.add_role(3)                             # add role (by ID) to the user
    u.remove_role(3)                          # remove role (by ID) from the user
    u.orders                                  # fetch the user's orders
    u.subscriptions                           # fetch the user's subscriptions

    o = Chord::Order.find('R87234695')        # fetch order by ID
    o.subscription_installment?               # was the order a subscription installment?
    o.subscription_start?                     # did the order start a subscription?

For complete/current list of supported objects and methods, please see the code.


## Querying

The most basic way to get a collection of objects:

    Chord::Order.all

You can also filter results by using `where`:

    Chord::Order.where('q[completed_at_gt]' => '2022-09-14')
    Chord::User.where('q[spree_roles_id_in]' => 8)


## Object attributes

Objects are constructed in a way that minimizes API calls but occasionally yields objects that seem incomplete. For example:

    orders = Chord::Order.all
    o = orders.first

will return a Chord::Order object with around 40 attributes, not the full set of 55 (it's missing line items, for example), because the `/orders` endpoint returns abbreviated objects. To load the full set of data for such an object, use the `expand!` method:

    o.expand!


# Configuration options

To get configuration data out of your code, put it in a YAML file, like so:

    # chord_config.yml
    base_url: https://...
    api_key: ...

and load it by calling:

    Chord.config_from_file('chord_config.yml')

Or put your config in environment variables:

    CHORD_BASE_URL=https://...
    CHORD_API_KEY=...

and load it by calling:

    Chord.config_from_env

Both config-loading methods return a boolean indicating whether configuration data was found and loaded, so you can easily fall back from one method to the other, for example:

    Chord.config_from_env or Chord.config_from_file('chord_config.yml')


# To Do

* tests should use mocks instead of real API requests
* support more objects and methods
