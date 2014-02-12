(($, Backbone) ->
    Backbone.emulateHTTP = true

    AjaxSettingsView = Backbone.View.extend {
        events:
            "change input:not(.ajax-ignore)": "persistChanges"
            "change select:not(.ajax-ignore)": "persistChanges"

        modelClass: AjaxSettingsModel
        formSelector: ajaxSetOpt.formSelector || 'form[action="options.php"]'
        updatedEls: {}

        initialize: (@opts) ->
            @setElement($(@formSelector))
            @hide()

            @model = new @modelClass(
                {},
                { form: @$el, parse: true, name: @opts.options_name}
            )

        hide: () ->
            @$el.hide()

        render: () ->
            if @$el.is(':not(:visible)')
                @refresh()
                @$el.fadeIn()
                @listenTo @model, 'change', @render
                @listenTo @model, 'change', @startUpdating
                @listenTo @model, 'sync', @updated

        refresh: () ->
            for inputName, v of @model.attributes
                inp = @model.findInput inputName
                if inp
                    inp.val v

        persistChanges: (e) ->
            e.preventDefault()
            @model.update(e.currentTarget)

        startUpdating: (obj, data) ->
            for name, x of obj.changed
                inp = @model.findInput(name)
                inp.val(x)
                @settingUpdateSent(inp)

        updated: (obj, data) ->
            for name, x of obj.changed
                @settingUpdateSuccess(@model.findInput(name))

        settingUpdateSent: (inp) ->
            return if not inp.length || @updatedEls[inp]

            el = @updatedEls[inp] = $('<div class="ajax-settings-updated">')
                .css
                    position: 'absolute'
                    left: inp.outerWidth() + inp.position().left
                    top: inp.position().top
                    visibility: 'hidden'
                .insertBefore inp

            el.css
                visibility: 'visible',
                marginTop: (inp.outerHeight() - el.outerHeight()) / 2

        settingUpdateSuccess: (inp) ->
            return if not inp.length || not @updatedEls[inp]
            $el = @updatedEls[inp]
            $el.addClass('success')
            setTimeout (() -> $el.remove()), 1000
            delete @updatedEls[inp]

    }, {
        extend: Backbone.View.extend
    }

    this.AjaxSettingsView = AjaxSettingsView

    $(document).ready () ->
        if ajaxSetOpt.initialize
            name = "#{ajaxSetOpt.options_name}AjaxSettingsView"
            window[name] = new AjaxSettingsView ajaxSettingsOptions

    $.fn.leftPositionWithPadding = () ->
        pos = this.position().left
        pos += this.width()
        if this.css 'padding-left'
            pos += parseInt this.css('padding-left')
        if this.css 'padding-right'
            pos += parseInt this.css('padding-right')
        if this.css 'border-left'
            pos += parseInt this.css('border-left')
        if this.css 'border-right'
            pos += parseInt this.css('border-right')
        pos

).call this, jQuery, Backbone

