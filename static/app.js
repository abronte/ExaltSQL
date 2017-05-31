var editor = ace.edit('editor');
editor.getSession().setMode('ace/mode/ruby');
editor.setShowPrintMargin(false);
editor.getSession().setTabSize(2);
editor.focus();

editor.setValue(`#Begin coding
data = query("select * from tpch.sf1.customer limit 5")
data = query("select count(*) FROM #{data.table}")
data.show()`);

editor.clearSelection();
editor.navigateFileEnd();

editor.commands.addCommand({
  name: 'run',
  bindKey: {win: "Shift-Enter", mac: "Shift-Enter"},
  exec: function(editor) {
    runBtn.run();
  }
});

Vue.component('result-table', {
  props: {
    columns: Array,
    data: Array
  },
  template: `
  <table class="table">
    <thead>
      <tr>
        <th v-for="key in columns">
          {{ key }}
        </th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="row in data">
        <td v-for="col in row">
          {{ col }}
        </td>
      </tr>
    </tbody>
  </table>`
});

var resultTable = new Vue({
  el: '#result',
  data: {
    tableColumns: [],
    tableData: []
  }
});

var runBtn = new Vue({
  el: '#run',
  data: {
    btnText: 'Run'
  },
  methods: {
    run: function(event) {
      self = this;
      self.btnText = 'Running...';
      code = editor.getValue();

      console.log('Run from view: '+code);

      $.ajax('/run', {
        data : JSON.stringify({'code': code}),
        contentType : 'application/json',
        dataType: 'JSON',
        type : 'POST',
        success: function(resp) {
          console.log(resp);
          self.btnText = 'Run';

          resultTable.tableColumns = resp['show']['cols'];
          resultTable.tableData = resp['show']['rows'];
        }
      });
    }
  }
});
