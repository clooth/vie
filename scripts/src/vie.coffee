# vie
# pixi renderer testing
# SETUP
class Vie
  @WIDTH:  1280
  @HEIGHT: 720

  stage: new PIXI.Stage 0xEEFFFF
  canvas: null

  constructor: () ->
    @renderer = PIXI.autoDetectRenderer Vie.WIDTH, Vie.HEIGHT
    @renderer.view.id = "vie"
    $("body").append @renderer.view
    @canvas = $("#vie")
    this.setup()

  setup: () ->
    $(window).on "resize", =>
      this.onResize.apply(this)
    this.onResize()

  onResize: () ->
    ww = window.innerWidth
    wh = window.innerHeight

    rw = 640
    rh = 360

    multiplier = Math.min (wh / rh), (ww / rw)
    nw = rw * multiplier
    nh = rh * multiplier

    @renderer.resize nw, nh
    @canvas.css({
      'margin-left': "-#{nw/2}px"
      'margin-top': "-#{nh/2}px"
    })

  start: () ->
    c.setup.apply  c, [this] for c in @components
    c.events.apply c, [this] for c in @components
    this.cycle()

  update: () ->
    c.update.apply c, [this] for c in @components

  render: () ->
    c.render.apply c, [this] for c in @components

  cycle: () ->
    callback = this.cycle.bind(this)
    requestAnimationFrame callback
    do this.update
    do this.render
    this.renderer.render(this.stage)

  # components
  components: []

  addComponent: (component) ->
    @components.push(component)


# TARGETING
class Targeting
  active: false

  source: null
  destination: null
  offset: null

  graphics: new PIXI.Graphics()

  constructor: () ->
    null

  reset: () ->
    @graphics.clear()
    @active = false
    @source = null
    @destination = null

  setup: (v) ->
    @offset = new PIXI.Point(
      v.canvas.offset().left
      v.canvas.offset().top
    )
    v.stage.addChild(@graphics)

  events: (v) ->
    # set source on click
    v.canvas.on "click", (e) =>
      console.log "targeting click"
      if @active is true
        this.reset()
        return

      # only update source if we're not active
      if @active is false
        @active = true
        @source = new PIXI.Point(
          e.pageX - @offset.x
          e.pageY - @offset.y
        )
        @destination = new PIXI.Point(
          e.pageX - @offset.x
          e.pageY - @offset.y
        )
        @active = true

    # update destination on mouse move
    v.canvas.on "mousemove", (e) =>
      if @active is false
        return

      console.log "targeting move"

      @destination = new PIXI.Point(
        e.pageX - @offset.x
        e.pageY - @offset.y
      )

    # cancel targeting if we go out of bounds
    v.canvas.on "mouseleave", (e) =>
      if @active is true
        console.log "targeting cancelled"
        this.reset()

  update: (v) ->
    @dashOffset++
    @dashOffset = 0 if @dashOffset > 20

  render: (v) ->
    if @active is true
      @graphics.clear()
      @graphics.lineStyle 10, 0xff0000, 1
      @graphics.moveTo @source.x, @source.y
      @graphics.lineTo @destination.x, @destination.y
      @graphics.endFill()


# start vie
vie = new Vie()
vie.addComponent new Targeting(vie)
vie.start()