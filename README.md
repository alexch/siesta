# Summary

Siesta is a Resource-centric webapp microframework. It rests (ahem) on two principles:

1. Automatic RESTful Routes
2. Flexible Layering

## Automatic RESTful Routes

Rails requires routes to be defined in a separate file from the controller. This separation can be confusing and redundant.

Sinatra routes are mere strings, and controllers (or handlers) are blocks defined next to those strings. This makes the linkage between routes and controllers very clear, but still has some limitations, notably that controllers are not objects, or even methods, and Sinatra apps are difficult to decompose. This means Sinatra apps have a ceiling of, say, a dozen or so routes before they get cumbersome and complex.

Siesta allows any object at all -- a Model, a View, or any arbitrary object -- to declare itself a Resource (or subresource). Siesta then automatically routes the correct URL path to it.

## Flexible Layering

The Model, View, Controller architecture has become dogma. Siesta uses an MVC architecture under the hood, but doesn't force app authors to use it explicitly. Instead, write the app you like, and let Siesta fill in the gaps.

If your Resource is a natural Model, then Siesta will use its standard controller to locate the appropriate object/s, instantiate it/them, then locate the appropriate view and render it.

If your Resource is naturally a View (say, an Erector class), then Siesta will use its standard controller to locate its object if necessary, and instantiate and render it. 

If Siesta can't find a view defined for your Resource, then it will use a standard view (similar to ActiveScaffold).

If your Resource implements Siesta controller methods, then it will call them instead of those on the standard controller.

Your Resource can also disable chosen REST methods, either permanently or depending on app state (e.g. the current user).

