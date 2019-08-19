$(window).load(function () {


    $(function () {
        //get Today's Date
        var currDate = new Date();
        $('#datetimepicker').datepicker({
            startDate: currDate

        });
    });


    $(document).ready(function () {
        $("#datepicker_start").datepicker({
            todayBtn: 1,
            autoclose: true,
            defaultDate: new Date()

        }).on('changeDate', function (selected) {
            var minDate = new Date(selected.date.valueOf());
            $('#datepicker_end').datepicker('setStartDate', minDate);
        });

        $("#datepicker_end").datepicker()
            .on('changeDate', function (selected) {
                var minDate = new Date(selected.date.valueOf());
                $('#datepicker_start').datepicker('setEndDate', minDate);
            });

        $('#enddate').datepicker('setStartDate', new Date());

        $("#startdate").datepicker({
            todayBtn: 1,
            autoclose: true,


        }).on('changeDate', function (selected) {
            var minDate = new Date(selected.date.valueOf());
            $('#enddate').datepicker('setStartDate', minDate);
        });

        $("#enddate").datepicker()
            .on('changeDate', function (selected) {
                var minDate = new Date(selected.date.valueOf());
                $('#startdate').datepicker('setEndDate', minDate);
            });

    });

    // Set Default Day to today
    var defaultDate = new Date()
    var $datepickerStart = $('#datepicker_start');
    $datepickerStart.datepicker('setDate', defaultDate);
    // Add one month to default date
    defaultDate.setMonth(defaultDate.getMonth() + 1);
    var $datepickerEnd = $('#datepicker_end');
    $datepickerEnd.datepicker('setDate', defaultDate);
});
