(($, Backbone) ->
    Backbone.emulateHTTP = true

    AjaxSettingsView = Backbone.View.extend {
        messageTemplate: _.template "<div class='updated ajax-settings-msg'>\
                            <p><%= message %></p>\
                         </div>"
        events:
            "change input:not(.ajax-ignore)": "persistChanges"
            "change select:not(.ajax-ignore)": "persistChanges"

        modelClass: AjaxSettingsModel
        el: 'form[action="options.php"]'
        successEls: {}

        initialize: (@opts) ->
            if @opts.formSelector
                @setElement($(opts.formSelector))

            @hide()

            @model = new @modelClass(
                {},
                _.extend { form: @$el, parse: true,}, @opts
            )

            @listenTo @model, 'change', @render
            @listenTo @model, 'change', @startUpdating
            @listenTo @model, 'sync', @updated

        hide: () ->
            @$el.hide()

        render: () ->
            for inputName, v of @model.attributes
                inp = @model.findInput inputName
                if inp
                    inp.val v

        show: () ->
            @$el.fadeIn()

        persistChanges: (e) ->
            e.preventDefault()
            @model.update(e.currentTarget)

        startUpdating: (obj, data) ->
            for name, x of obj.changed
                @settingUpdateSent(@model.findInput(name))

        updated: (obj, data) ->
            @render()
            for name, x of obj.changed
                @settingUpdateSuccess(@model.findInput(name))

        settingUpdateSent: (inp) ->

        settingUpdateSuccess: (inp) ->
            return if not inp.length || @successEls[inp]
            $el = $(@messageTemplate message: "Setting saved.").hide()
            @successEls[inp] = $el.insertAfter(inp).slideDown()
            setTimeout(
                () => 
                    $el.slideUp()
                    delete @successEls[inp]
            , 2000)

    }, {
        extend: Backbone.View.extend
    }

    this.AjaxSettingsView = AjaxSettingsView

    $(document).ready () ->
        if ajaxSetOpt.initialize
            name = "#{ajaxSetOpt.options_name}AjaxSettingsView"
            window[name] = new AjaxSettingsView ajaxSetOpt

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

