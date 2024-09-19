# Contributing to Clicked

Clicked uses a strict set of code standards and guidelines, this document will outline those as well as the high-level architecture of the addon.

## Code standards

* Use tabs, not spaces
* Trailing whitespaces are not allowed
* Place an empty newline at the end of file
* Line endings must be CLRF
* Avoid using semicolons at the end of a line

The project contains an `.editorconfig` file which enforces most of these rules automatically if your editor supports it.

## Pull Requests

In order to submit code changes, a pull request is required. For this you will need a GitHub account.

1. [Fork](https://github.com/Snakybo/Clicked/fork) this repository
2. Add the bugfix, change, or new feature to your local forked repository
3. Commit and push your changes
4. [Open a pull request](https://github.com/SnakyboWeakAuras/Clicked/pulls) with a description of what your change entails

## Reporting Issues

Issues can be reported on the [Issue Tracker](https://github.com/Snakybo/Clicked/issues).

## Requesting features

New features, or changes to an existing feature can be requested via the [Discussions](https://github.com/Snakybo/Clicked/discussions) page. Open a new
discussion, or contribute to an existing discussion within the Ideas category.

## High-level architecture

Clicked is designed to be relatively loosely coupled. Configuration is separated from the runtime, and the runtime is split up into three distinct stages
with three different states:

1. [Binding processing](#binding-processing)
2. [Command processing](#command-processing)
3. [Attribute handling](attribute-handling)

### Binding processing

The binding processing stage takes the raw configuration from the database and generates a set of "commands". Prior to generating commands, this decides
whether a binding should currently be active, and seperates a binding into two "buckets"; a bucket containing the regular bindings, and a bucket containing the
click-cast/hovercast bindings.

This is an important distinction because these "buckets" will go through the next stages seperately and behave slightly different.

A binding is determined to be active when all of its load conditions are currently valid. Due to addon restrictions, the active state of a binding cannot change
whilst the player is in combat, however there are a handful of load options that can change during combat, such as the stance/aura or pet options. Those load
conditions are ignored during this process, as those all convert to valid macro conditions (`stance:`, `form:`, `pet`, `nopet`, etc.).

If there are multiple bindings configured onto the same keybind, this processor will condense those bindings into one which is then used to generate a single
macro for the command. The player's configuration input on the configuration's "Targets" page is all sorted, weighted, and translated into a single macro that
WoW can understand.

When all configured bindings have been processed (validated active state and split into buckets), the processor will output a list of commands. A command is in
many ways a simplified form for a binding's data with all the irrelevant configuration data stripped out. A command consists out of a few properties:

* `keybind`:`string`
* `hovercast`:`boolean`
* `prefix`:`string`
* `suffix`:`string`
* `action`:`string`
* `data`:`string`

The `keybind` property is pretty self-explanatory, it's the keybind assigned to the binding(s) that generated this command. The `hovercast` property is a
boolean that is set to `true` for commands that have been generated from the hovercast "bucket".

The `prefix` and `suffix` properties are a variation of the `keybind`, but then split into a prefix (modifier keys) and suffix (the activation key).

The `action` property refers to the type of command this is, which can either be a `macro`, `target`, or `menu`. And finally the `data` property is the data
that is associated with the command, if the `action` property is `target` or `menu`, this will be `nil`, if it's a `macro` it will contain the raw macro string.

### Command processing

After the binding processor has finished, it will invoke the command processor. The command processor converts the addon data into WoW-compatible attribute
data. Clicked uses two WoW frames to handle keybinds:

* The `MacroFrameHandler`
* The `ClickCastHeader`

The `MacroFrameHandler` is used for all commands that have the `hovercast` property set to `false`. This frame intercepts key presses and clicks globally and
thus does not require the mouse cursor to be on top of a unitframe. This contains additional code to automatically disable Clicked keybinds when the player has
an overriden action bar or is in a vehicle, so that they can use their overriden abilities with normal keybinds.

The `ClickCastHeader` is a global frame which also allows for third-party addon integration, see [Integrating Clicked](#integrating-clicked) for a detailed
explaination of the `ClickCastHeader` frame.

The command processor is tightly coupled with the attribute handler, firstly it will simplify the input commands into an even simpler data structure, which is
then converted into the parameters required for WoW frame attributes and keybinds, afterwars the data is sent to the attribute handler and queued for
processing.

### Attribute handling

When all commands have been processed and the data has been injected into the attribute handler, all frames will be ready for attribute injection.

This happens in two steps, firstly, the [SecureActionButtonTemplate](https://wow.gamepedia.com/SecureActionButtonTemplate) attributes are set to perform an
action when an identifier is invoked.

Secondly, set up two custom attributes: `clicked-keybinds` and `clicked-identifiers` to handle the binding and unbinding of keys. These attributes contain
all keybinds and their associated identifiers (that were used for the SecureActionButtonTemplate). This is what finally causes a button press to invoke an
action.

## Integrating Clicked

If you have a custom unitframe addon and wish to integrate click-cast support, this should help you get started.

First and foremost, Clicked aims to be integration-free, and no support to manually register a frame. Instead, Clicked uses a global table
which can be used by other click-cast addon implementations so no custom implementations are needed.

The global table that is used for this is the `ClickCastFrames` table, registering a frame using this table is as simple as setting
`ClickCastFrames[myFrame] = true` to register a frame, or `ClickCastFrames[myFrame] = false` to unregister a frame.

In addition to the global `ClickCastFrames` table, it is also possible to register frames using protected code which is ran within attributes, this can be done
using the global `ClickCastHeader` frame. This frame has a `clickcast_register` and `clickcast_unregister` attribute which can be executed from within your
own protected code if you set a frame reference to the `ClickCastHeader` frame:

```lua
myFrame:SetAttribute("my-registration-attribute", [[
	local header = self:GetFrameRef("clickcast_header")
	header:SetAttribute("clickcast_button", self)
	header:RunAttribute("clickcast_register")
]])
```

In a similar vein, the `ClickCastHeader` also supports attributes for `OnEnter` and `Onleave` events, which can be used if your frame does not support the
standard `OnEnter`/`OnLeave` script wrapping. These can be invoked using the `clickcast_onenter` and `clickcast_onleave` attributes.

It is also possible have your frames inherit the `ClickCastUnitTemplate`, which will automatically implement the `clickcast_onenter` and `clickcast_onleave`
handlers.
