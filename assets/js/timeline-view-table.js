window.addEventListener("touchmove", function (event) {
  event.preventDefault();
}, {
  passive: false
});

var startDate = new Date(document.getElementById('startDate').innerHTML);
var endDate = new Date(document.getElementById('endDate').innerHTML);

endDate.setDate(endDate.getDate() + 1);
var dataLength = document.getElementById('dataLength').innerHTML

var minTime = moment().add(-6, 'months').valueOf()
var maxTime = moment().add(6, 'months').valueOf()

var props = {
  groups: groups,
  items: items,
  fixedHeader: 'fixed',
  canMove: false, // defaults
  canResize: true,
  itemsSorted: true,
  itemTouchSendsClick: false,
  stackItems: true,
  itemHeightRatio: 0.75,
  dragSnap: moment.duration(1, 'days').asMilliseconds(),
  defaultTimeStart: startDate,
  defaultTimeEnd: endDate,

  maxZoom: moment.duration(2, 'months').asMilliseconds(),
  minZoom: moment.duration(3, 'days').asMilliseconds(),

  keys: {
    groupIdKey: 'id',
    groupTitleKey: 'title',
    itemIdKey: 'id',
    itemTitleKey: 'title',
    itemGroupKey: 'group',
    itemTimeStartKey: 'start',
    itemTimeEndKey: 'end'
  },

  onItemClick: function (item) {
    console.log("Clicked: " + item);
  },

  onItemSelect: function (item) {
    console.log("Selected: " + item);
  },

  onItemContextMenu: function (item) {
    console.log("Context Menu: " + item);
  },


  // this limits the timeline to -6 months ... +6 months
  onTimeChange: function (visibleTimeStart, visibleTimeEnd) {
    if (visibleTimeStart < minTime && visibleTimeEnd > maxTime) {
      this.updateScrollCanvas(minTime, maxTime)
    } else if (visibleTimeStart < minTime) {
      this.updateScrollCanvas(minTime, minTime + (visibleTimeEnd - visibleTimeStart))
    } else if (visibleTimeEnd > maxTime) {
      this.updateScrollCanvas(maxTime - (visibleTimeEnd - visibleTimeStart), maxTime)
    } else {
      this.updateScrollCanvas(visibleTimeStart, visibleTimeEnd)
    }
  }

}
var filter = React.createElement("div", {}, "Approved requests");

/* jshint undef:false */
ReactDOM.render(React.createElement(ReactCalendarTimeline['default'], props, filter), document.getElementById('main'));