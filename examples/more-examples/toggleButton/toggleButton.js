/**
@example_title uki.more Toggle Button
@example_order 4105
@example_html
    <div id='test' style='width: 50%; height: 100px; background: #EEE'>#test</div>
    <script src="/src/uki.cjs"></script>
    <script src="/src/uki-more/more/view/toggleButton.cjs"></script>
    <script src="toggleButton.js"></script>
*/

uki([
    { view: 'uki.more.view.ToggleButton', rect: '90px 40px 100px 24px', text: 'Toggle me' },
    { view: 'uki.more.view.ToggleButton', rect: '210 40 100 24', text: 'Me to' }
]).attachTo( document.getElementById('test'), '400px 100px' );
