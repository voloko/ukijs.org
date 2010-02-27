uki({ view: 'Button', rect: '0 0 180 24', anchors: 'left top', text: 'Run code >>' })
    .attachTo( document.getElementById('runner') )
    .click(function() {
        uki({ view: "Button", text: "Hello world!", rect: "120 80 180 24" })
            .attachTo( document.getElementById("test") );
        
        uki("Button[text^=Hello]").click(
          function() { alert(this.text()); }
        );

        this.unbind('click', arguments.callee);
    });
    

var VimeoVideo = uki.newClass(uki.view.Base, new function() {
    var Base = uki.view.Base.prototype;
    
    var template = new uki.theme.Template(
        '<div style="background:url(/i/close.png) no-repeat left top;height:13px;padding-left:16px;cursor:pointer;position:absolute;right:0;top:-16px;color:#999;font-size:12px;">close</div>' + 
        '<object width="${width}" height="${height}">' +
            '<param name="allowfullscreen" value="true" /><param name="allowscriptaccess" value="always" />' +
            '<param name="movie" value="${src}" />' +
            '<embed src="${src}" type="application/x-shockwave-flash" allowfullscreen="true" ' +
                'allowscriptaccess="always" width="${width}" height="${height}"></embed>' +
        '</object>'
    );
    
    this.typeName = function() { return 'VimeoVideo'; };
    
    this.movieSrc = uki.newProp('_movieSrc');
    this.movieSize = uki.newProp('_movieSize', function(v) {
        this._movieSize = uki.geometry.Size.create(v);
        this.rect(this._parentRect);
    });
    
    this.layout = function() {
        if (!this._movieInited) {
            this._movieInited = true;
            var container = uki.createElement('div', '', template.render({
                src: this.movieSrc(),
                width: this.movieSize().width,
                height: this.movieSize().height
            }));
            this._dom.appendChild(container);
            uki.dom.bind(container.firstChild, 'click', uki.proxy(function() {
                this.visible(false);
            }, this));
        }
        Base.layout.call(this);
    };
});
var videos = [];
var urls = [
    'http://vimeo.com/moogaloop.swf?clip_id=8995996&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1',
    'http://vimeo.com/moogaloop.swf?clip_id=9020120&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1',
    'http://vimeo.com/moogaloop.swf?clip_id=9020286&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1'
];

uki.each([1, 2, 3], function(i, n) {
    uki.dom.bind(document.getElementById('screencast' + n), 'click', function() {
        if (!videos[i]) {
            videos[i] = uki({ 
                view: 'VimeoVideo', rect: '200 -100 600 375', movieSize: '600 375', 
                shadow: 'theme(shadow-big)',
                movieSrc: urls[i],
                anchors: 'left top' 
            }).attachTo(document.getElementById('screencasts'));
        }
        videos[i].visible(true).layout();
    });
});
