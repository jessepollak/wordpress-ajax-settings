(($, Backbone) ->
    AjaxSettingsModel = Backbone.Model.extend
        url: ajaxurl + "?action=ajax_settings_save"
        options: {}
        sync: (method, model, options) ->
            options = options || {}
            options.emulateHTTP = true

            data = model.toJSON()
            data = @addActionToData(data)
            if @options.network_wide
                data.network_wide = true

            options.data = $.param(data)
            options.dataType = 'json'
            # coffeelint: disable=max_line_length
            options.contentType = 'application/x-www-form-urlencoded; charset=UTF-8'
            # coffeelint: enable=max_line_length
            options.processData = false

            Backbone.Model.prototype.sync.call(this, method, model, options)
        parse: (data, options)->
            # initialize
            if options.form
                @options = options
                # coffeelint: disable=max_line_length
                @url = "#{ajaxurl}?action=ajax_settings_save_#{@options.options_name}"
                # coffeelint: enable=max_line_length
                if @options.url
                    @url = @options.url

                if @options.network_wide
                    @url += "&network_wide=true"

                @$form = @options.form
                _.extend data, @$form.serializeObject()

        addActionToData: (data) ->
            data.action = "ajax_settings_save_#{@options.options_name}"
            data
        isNew: () -> false
        update: (el) ->
            $el = $(el)
            if $el.is(':checkbox')
                el.value = if $el.is(':checked') then 1 else 0

            @saving = true
            @save el.name, el.value,
                success: @saveSuccess.bind(this)
                error: @saveError.bind(this)

        saveSuccess: (obj, data) ->
            @saving = false
        saveError: (obj, data) ->
            @saving = false

        findInput: (name, opts={}) ->
            if !@_is
                @_is = {}

            if !@_is[name]
                @_is[name] = @$form
                    .find('input, select, textarea')
                    .filter("[name='#{name}']")

            @_is[name]

    $.fn.serializeObject = (form) ->
        serialized = {}
        for obj in $(this).serializeArray()
            serialized[obj.name] = obj.value
        serialized

    AjaxSettingsModel.extend = Backbone.Model.extend
    this.AjaxSettingsModel = AjaxSettingsModel

).call(this, jQuery, Backbone)
