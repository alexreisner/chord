# Changelog

Major changes for each release. Please see the Git log for complete list of changes.

## 0.0.10

* Don't allow public writing of @attributes.
* Add Order#complete? method.

## 0.0.9

* When API error on update, don't update object attributes.

## 0.0.8

* Don't preserve existing attributes when calling `expand!`.
* Add User#orders method.

## 0.0.7

* Remove ActiveRecord dependency.
* Make some methods private.
* Raise APIError when no data returned.

## 0.0.6

* Return User objects from Role#users.
* Add config methods.

## 0.0.5

* Add expand! method.
* Fix Order object IDs.

## 0.0.4

* Load subscription_in_cart attribute if missing when it's needed.

## 0.0.3

* Refactor configuration.

## 0.0.2

* Don't memoize filtered queries.

## 0.0.1

* Very rudimentary start, focused on the parts of the API I need to use.

