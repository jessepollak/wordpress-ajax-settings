(($, Backbone) ->
    Backbone.emulateHTTP = true

    AjaxSettingsView = Backbone.View.extend {
        messageTemplate: _.template "<div class='<%=type%> ajax-settings-msg'>\
                            <p><%= message %></p>\
                         </div>"
        events:
            "change input:not(.ajax-ignore)": "persistChanges"
            "change select:not(.ajax-ignore)": "persistChanges"

        modelClass: AjaxSettingsModel
        el: 'form[action="options.php"]'
        successEls: {}
        errorEls: {}
        genericErrorMessage: "Something went wrong, \
        please refresh and try again."
        successMessageDisplayTime: 3000

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
            @listenTo @model, 'error', @error
            @listenTo @model, "change", @clearErrors

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

        error: (obj, data) ->
            if !data.responseJSON || !data.responseJSON.data
                @showMessage
                    message: @genericErrorMessage
                    type: "error"
                return

            if !data.responseJSON.data.errors && data.responseJSON.data.error
                @showMessage
                    message: data.responseJSON.data.error
                    type: "error"
                return

            for inputName, msg of data.responseJSON.data.errors
                @settingsUpdateError(
                    @model.findInput("#{@opts.options_name}[#{inputName}]"),
                    msg
                )

        clearErrors: (model, data) ->
            # when a model changes, if it previously was error'd, clear them
            # so we can reshow them (or do away with them) on model save
            if @globalError
                @globalError.remove()
                @globalError = null

            for inputName, v of model.changed
                inp = @model.findInput(inputName)
                if @errorEls[inp]
                    @errorEls[inp].remove()
                    @errorEls[inp] = null

        settingUpdateSent: (inp) ->

        settingUpdateSuccess: (inp) ->
            return if not inp.length || @successEls[inp]
            $el = $(@messageTemplate
                message: "Setting saved.",
                type: "updated"
            ).hide()
            @successEls[inp] = $el.insertAfter(inp).slideDown()
            setTimeout(
                () =>
                    $el.slideUp()
                    delete @successEls[inp]
            , @successMessageDisplayTime)

        settingsUpdateError: (inp, msg) ->
            if @errorEls[inp]
                @errorEls[inp].find('p').html msg
            else
                $el = $(@messageTemplate message: msg, type: "error").hide()
                @errorEls[inp] = $el.insertAfter(inp).slideDown()

        showMessage: (opts) ->
            $el = $(@messageTemplate opts).hide()
            @globalError = $el.prependTo(@$el).slideDown()
            $('html, body').animate scrollTop: @$el.scrollTop(), "slow"

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

