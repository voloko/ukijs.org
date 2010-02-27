/**
@example_title Slider
@example_order 3122
@example_html
    <div id='test' style='width: 50%; height: 100px; background: #EEE'>#test</div>
    <script src="/src/uki.cjs"></script>
    <script src="slider.js"></script>
*/

uki({ view: 'Slider', rect: '100px 38px 400px 24px', anchors: 'left width top' })
    .attachTo( document.getElementById('test'), '500px 100px' );

