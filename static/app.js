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
editor.getSession().setUseWrapMode(true);

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
  <table class="table" v-if="data.length > 0">
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

Vue.component('result-error', {
  props: {
    error: String
  },
  template: `
  <pre class="alert alert-danger" v-if="error">
  {{ error }}
  </pre>
  `
});

Vue.component('result-stdout', {
  props: {
    stdout: String
  },
  template: '<pre v-if="stdout">{{ stdout }}</pre>'
});


var resultTable = new Vue({
  el: '#result',
  data: {
    tableColumns: [],
    tableData: []
  }
});

var resultError = new Vue({
  el: '#error',
  data: {
    errorData: undefined
  }
});

var resultStdout = new Vue({
  el: '#stdout',
  data: {
    stdoutData: undefined
  }
});

var runBtn = new Vue({
  el: '#run',
  data: {
    btnText: 'Run',
    has_result: false,
    submitted: false
  },
  created: function() {
    this.check();
  },
  methods: {
    resetOutput: function() {
      resultTable.tableData = [];
      resultError.errorData = undefined;
      resultStdout.stdoutData = undefined;
    },
    displayResp: function(resp) {
      this.btnText = 'Run';
      this.submitted = false;

      if (resp['error']) {
        resultError.errorData = resp['error'];
      } else {
        if (resp['show']) {
          resultTable.tableColumns = resp['show']['cols'];
          resultTable.tableData = resp['show']['rows'];
        }

        if (resp['stdout']) {
          resultStdout.stdoutData = resp['stdout'];
        }
      }

      self.has_result = false;
    },
    check: function() {
      console.log('Checking...');

      self = this;

      if (!self.has_result) {
        $.ajax('/check', {
          contentType : 'application/json',
          dataType: 'JSON',
          type : 'GET',
          success: function(resp) {
            console.log(resp);

            if (resp['running']) {
              self.btnText = 'Running...';
              setTimeout(self.check, 1000);
            } else {
              self.has_result = true;
              self.displayResp(resp);
            }
          }
        });
      }
    },
    run: function(event) {
      self = this;

      if (self.submitted) {
        return
      }

      self.resetOutput();
      self.btnText = 'Running...';
      self.submitted = true;
      code = editor.getValue();

      console.log('Running: '+code);

      $.ajax('/run', {
        data : JSON.stringify({'code': code}),
        contentType : 'application/json',
        dataType: 'JSON',
        type : 'POST',
        success: function(resp) {
          console.log(resp);
          self.check();
        }
      });
    }
  }
});
