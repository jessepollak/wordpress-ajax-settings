(($, Backbone) ->
    AjaxSettingsView = Backbone.View.extend {
        messageTemplate: _.template "<div class='<%=type%> ajax-settings-msg'>\
                            <p><%= message %></p>\
                         </div>"
        events:
            "change input:not(.ajax-ignore)": "persistChanges"
            "change select:not(.ajax-ignore)": "persistChanges"
            "change textarea:not(.ajax-ignore)": "persistChanges"

        modelClass: AjaxSettingsModel
        el: 'form[action="options.php"]'
        genericErrorMessage: "Something went wrong: "
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
                    if inp.is(':checkbox')
                        inp.prop 'checked', parseInt(v)
                    else
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
                    message: "#{@genericErrorMessage} #{data.responseText}"
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
                if inp.data 'errorEl'
                    inp.data('errorEl').remove()
                    inp.data 'errorEl', null
        settingUpdateSent: (inp) ->
        settingUpdateSuccess: (inp) ->
            return if not inp.length || inp.data('successEl')
            $el = $(@messageTemplate
                message: "Setting saved.",
                type: "updated"
            ).hide()
            inp.data 'successEl', $el.insertAfter(inp).slideDown()
            setTimeout(
                () ->
                    $el.slideUp()
                    inp.data 'successEl', null
            , @successMessageDisplayTime)

        settingsUpdateError: (inp, msg) ->
            if inp.data 'errorEl'
                inp.data('errorEl').find('p').html msg
            else
                $el = $(@messageTemplate message: msg, type: "error").hide()
                inp.data 'errorEl', $el.insertAfter(inp).slideDown()

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

