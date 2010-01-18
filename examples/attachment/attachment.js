/**
@example_title Hello world
@example_html
    <div id='test' style='width: 50%; height: 100px; background: #EEE'>#test</div>
    <script src="/uki-core/uki.cjs"></script>
    <script src="attachment.js"></script>
*/

uki({
    view: 'Button',
    rect: '200px 40px 200px 24px',
    text: 'uki is awesome!'
}).attachTo( document.getElementById('test'), '600px 100px' );

uki('Button[text^=uki]').bind('click', function() {
    alert('Hello world!');
});
