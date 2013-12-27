

setup-routes = ($route-provider) ->
    $route-provider.when '/',               { controller: 'appCtrl',     template-url: '/html/example-view.html'   }
                   .otherwise redirect-to: '/'

#Main entry point of the application
application = angular.module('application', ['ui.bootstrap.datetimepicker', 'ngRoute'])

application.config(setup-routes)

application.controller 'appCtrl', ($scope) ->
    $scope.status = 'ok'
    load-data($scope)
    load-icons('data/icons.svg')


load-icons = (url) ->
      c = new XMLHttpRequest() 
      c.open('GET', url, false) 
      c.setRequestHeader('Content-Type', 'text/xml')
      c.send()
      document.body.insertBefore(c.responseXML.firstChild, document.body.firstChild)


histo = (id, min, max, facts, param) ->

        par-hist = dc.bar-chart(id)
        par-dim  = facts.dimension param

        par-hist
        .width(400)
        .height(160)
        .margins(top: 10, right: 10, bottom: 20, left: 40)
        .dimension( par-dim )
        .group( par-dim.group().reduce-count( param ) )
        .transition-duration(500)
        .center-bar(true)
        .x(d3.scale.linear().domain([min, max]))
        .gap(65)
        .elastic-y(true)
        .x-axis()
        .tick-format()

pie = (id, facts, param) ->
        pn-pie      = dc.pie-chart(id)
        pn-pie
        .width(240)
        .height(120)
        .radius(60)
        .inner-radius(15)
        .dimension(facts.dimension param )
        .group( (facts.dimension param).group() )
        .title( param )    

load-data = ($scope) ->
    d3.json "data/test.json", (data) ->

        for d in data 
            delete d[""]
            d.cyc = d3.round(d.cycles/(100000000), 2)
            d.en = d3.round(d.energy, 2)

        data-table  = dc.data-table('#data-table')

        facts       = crossfilter(data)

        data-table
        .width(960)
        .height(800)
        .dimension(facts.dimension (.cycles) )
        .group( (.pn) )
        .size(10)
        .columns [
                    (.pn)
                    (.ics)
                    (.dcs)
                    (.l2cs)
                    (.icw)
                    (.dcw)
                    (.l2cw)
                    (.iwidth)
                    (.cbs)
                    (.en)
                    (.cyc)
                    ]
        .sort-by (.cyc)
        .order(d3.ascending)


        histo('#cycles-hist' , 0     , 6          , facts , (.cyc))
        histo('#energy-hist' , 0     , 14         , facts , (.en))
        pie('#pn-pie'        , facts , (.pn))
        pie('#iw-pie'        , facts , (.iwidth))
        pie('#ics-pie'       , facts , (.ics))
        pie('#dcs-pie'       , facts , (.dcs))
        pie('#icw-pie'       , facts , (.icw))
        pie('#dcw-pie'       , facts , (.dcw))
        pie('#l2cw-pie'       , facts , (.l2cw))
        pie('#l2cs-pie'       , facts , (.l2cs))

        dc.renderAll()



