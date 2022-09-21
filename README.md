# Chord Commerce OMS API Gem

These classes provide simple read and write access to the Chord OMS API. Get started like this:

    Chord.config(
      base_url: 'https://<customer>.staging.assembly-api.com/api/',
      api_key: '<key>'
    )

    u = Chord::User.find(1)                   # fetch user
    u.attributes                              # see attributes hash
    u.update(name: 'New Name', notes: 'Etc')  # update attributes
    u.update(metadata: {ambassador_id: 415})  # when updating 'metadata' attribute, the given
                                              # hash is merged into the existing value and
                                              # keys and values are stringified (since
                                              # metadata is stored in OMS as a JSON string)
    u.add_role(3)                             # add role (by ID) to the user
    u.remove_role(3)                          # remove role (by ID) from the user
    u.subscriptions                           # fetch the user's subscriptions

Objects are constructed in a way that minimizes API calls but occasionally yields objects that seem incomplete. For example:

    orders = Chord::Order.all
    o = orders.first

will return a Chord::Order object with around 40 attributes, not the full set of 55 (it's missing line items, for example), because the `/orders` endpoint returns abbreviated objects. To load the full set of data for these objects, use the `expand!` method:

    o.expand!

