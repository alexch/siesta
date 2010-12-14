# STATUS: UNDER DEVELOPMENT

This is pre-alpha code. YMMV, caveat emptor. It's probably not even working yet.

# Summary

Siesta is a Resource-centric webapp microframework. It rests (ahem) on two principles:

1. Automatic RESTful Routes
2. Flexible Layering

## Automatic RESTful Routes

Rails requires routes to be defined in a separate file from the controller. This separation can be confusing and redundant.

Sinatra routes are mere strings, and controllers (or handlers) are blocks defined next to those strings. This makes the linkage between routes and controllers very clear, but still has some limitations, notably that controllers are not objects, or even methods, and Sinatra apps are difficult to decompose. This means Sinatra apps have a ceiling of, say, a dozen or so routes before they get cumbersome and complex.

Siesta allows any object at all -- a Model, a View, or any arbitrary object -- to declare itself a Resource (or subresource). Siesta then automatically routes the correct URL path to it.

Paths are based on the resource's class name, but can be overridden or added.

## Flexible Layering

The Model, View, Controller architecture has become dogma. Rails in particular, at least by convention, prefers apps to be medium-sized: more than, say, 20 resources, or less than 5, and Rails causes pain.

Siesta uses an MVC architecture under the hood, but doesn't force app authors to use it explicitly. Instead, structure the app how you like, and let Siesta fill in the gaps.

If your Resource is a natural Model (e.g. ActiveRecord), then Siesta will use its standard controller to locate the appropriate object/s, instantiate it/them, then locate the appropriate view and render it.

If your Resource is a natural View (say, an Erector class), then Siesta will use its standard controller to locate its object if necessary, and instantiate and render it.

If Siesta can't find a view defined for your Resource, then it will use a standard view (similar to ActiveScaffold).

If your Resource implements Siesta controller methods, then it will call them instead of those on the standard controller.

Your Resource can also disable chosen REST methods, either permanently or depending on app state (e.g. the current user).

If your Resource is a natural Command, then the standard controller will invoke its `perform` method in response to a POST or PUT.

## Opinionated REST

Definitions:

**part** A subresource.

**collection** A resource that represents a collection of other resources, all of the same type.

**item** A resource with an id that is strictly an instance of its parent collection resource.

**perspective** A part that's just a view on that resource. E.g. "/user/new" or "/user/12/edit" or "/dashboard/activity/by_date".

**action** A part that alters the parent resource, e.g. "/user/12/suspend". (Be sure you really want to do this instead of "POST /user/12/suspension" since the latter supports DELETE etc.)

TODO: Re-read the REST paper to see if he's got better names already.

Examples:

/foo --
    "foo" is a unitary resource since it's at root level

/dog/123/name --
    "dog" is unitary since it represents the set of all dogs (many dogs, but only one set).
    "name" is a subresource since there's only one name per dog.
    "dog/123" is an indexed resource

All names are singular. (For collections, we may want to optionally allow plurals to work as well as the singular form.)

Searches are a GET against the collection.

# Related Projects

<https://github.com/voxdolo/decent_exposure>
<https://github.com/jamesgolick/resource_controller>
<https://github.com/ianwhite/resources_controller>

