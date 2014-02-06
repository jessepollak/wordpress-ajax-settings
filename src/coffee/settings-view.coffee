(($, Backbone) ->
    Backbone.emulateHTTP = true

    AjaxSettingsView = Backbone.View.extend {
        events:
            "change input:not(.ajax-ignore)": "persistChanges"
            "change select:not(.ajax-ignore)": "persistChanges"
            "click input[type='submit']:not(.ajax-ignore)": "persistChanges"

        modelClass: AjaxSettingsModel
        formSelector: 'form[action="options.php"]'
        updatedEls: {}

        initialize: (@opts) ->
            @setElement($(@formSelector));
            @hide()

            @model = new @modelClass(
                {}, 
                { form: @$el, parse: true, name: @opts.options_name}
            )
            @listenTo @model, 'change', @render
            @listenTo @model, 'change', @startUpdating
            @listenTo @model, 'sync', @updated

        hide: () ->
            @$el.hide()

        render: () ->
            if @$el.is(':not(:visible)')
                @$el.fadeIn()

        persistChanges: (e) ->
            e.preventDefault()
            @model.update(e.currentTarget)

        startUpdating: (obj, data) ->
            for name, x of obj.changed
                @settingUpdateSent(@model.findInput(name))

        updated: (obj, data) ->
            for name, x of obj.changed
                @settingUpdateSuccess(@model.findInput(name))

        settingUpdateSent: (inp) ->
            return if @updatedEls[inp]
            el = @updatedEls[inp] = $('<div class="ajax-settings-updated">')
                .css
                    left: inp.leftPositionWithPadding()
                    top: inp.position().top
                    display: 'none'
                .insertAfter inp
            el.show()

        settingUpdateSuccess: (inp) ->
            return if not @updatedEls[inp]
            $el = @updatedEls[inp]
            $el.addClass('success')
            setTimeout (() -> $el.remove()), 1000
            delete @updatedEls[inp]

    }, {
        extend: Backbone.View.extend
    }

    this.AjaxSettingsView = AjaxSettingsView

    $(document).ready () ->
        if ajaxSettingsOptions.initialize
            window["#{ajaxSettingsOptions.options_name}AjaxSettingsView"] = new AjaxSettingsView ajaxSettingsOptions

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

