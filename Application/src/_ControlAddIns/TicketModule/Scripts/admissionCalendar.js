(function () {
    "use strict";

    var HOUR_PX = 48;
    var GRID_PAD_MINUTES = 10; // air between the ribbon and a block starting exactly on the first hour
    var locale = (navigator.language || 'en');

    // Slot data lives outside Vue reactivity - a month of dense schedules is ~1700 rows and the views
    // only need to re-render when a payload arrives, which `state.version` signals.
    var data = {
        slotsByDate: Object.create(null),
        loadedDates: new Set()
    };

    var state = Vue.reactive({
        ctx: null,          // { admissionCode, admissionDescription, today, nowTime, captions }
        view: 'week',       // 'week' | 'month'
        anchor: null,       // ISO date; week = first visible day, month = any day in the month
        version: 0,
        pending: null,      // 'from|to' of the in-flight request
        silentPending: null, // 'from|to' of an in-flight background revalidation - never surfaces the loading pill
        selected: null,     // slot shown in the detail card
        focused: null       // slot hovered on the day timeline - lights up its sell/arrival bands
    });

    // ---------- date helpers (ISO strings, UTC math and UTC formatting so neither DST nor the browser's zone can shift a date) ----------

    function addDays(iso, n) {
        var d = new Date(iso + 'T00:00:00Z');
        d.setUTCDate(d.getUTCDate() + n);
        return d.toISOString().slice(0, 10);
    }

    function dayOfWeek(iso) { // 0 = Monday .. 6 = Sunday
        return (new Date(iso + 'T00:00:00Z').getUTCDay() + 6) % 7;
    }

    function monthStart(iso) { return iso.slice(0, 8) + '01'; }

    function addMonths(iso, n) {
        var d = new Date(iso.slice(0, 8) + '01T00:00:00Z');
        d.setUTCMonth(d.getUTCMonth() + n);
        return d.toISOString().slice(0, 10);
    }

    function toMinutes(time) {
        if (!time) return null;
        var p = time.split(':');
        return (+p[0]) * 60 + (+p[1]);
    }

    function fmtTime(time) { return time ? time.slice(0, 5) : ''; }

    // A BC time serializes 0T (unset) as "00:00:00" - treat that, and empty, as "no edge set" so the
    // arrival window falls back to the slot bounds exactly the way GetAdmScheduleEntry does at the gate.
    function timeSet(time) { return !!time && time.slice(0, 8) !== '00:00:00'; }

    function fmt(iso, options) {
        if (!iso) return '';
        return new Intl.DateTimeFormat(locale, Object.assign({}, options, { timeZone: 'UTC' })).format(new Date(iso + 'T00:00:00Z'));
    }

    // ---------- visible range and data protocol ----------

    function visibleRange() {
        if (state.view === 'day')
            return { from: state.anchor, to: state.anchor };
        if (state.view === 'week')
            return { from: state.anchor, to: addDays(state.anchor, 6) };
        if (state.view === 'month') {
            var gridStart = addDays(monthStart(state.anchor), -dayOfWeek(monthStart(state.anchor)));
            return { from: gridStart, to: addDays(gridStart, 41) };
        }
        return null; // year view is navigation only - a year of slots would blow the request budget
    }

    function refresh() {
        if (!state.ctx || !state.ctx.admissionCode) return;
        var range = visibleRange();
        if (!range) return;
        var covered = true;
        for (var d = range.from; d <= range.to; d = addDays(d, 1))
            if (!data.loadedDates.has(d)) { covered = false; break; }
        if (covered) {
            // Older days hardly change, but a slot that started yesterday can still be admitting past midnight.
            var from = (range.from > addDays(state.ctx.today, -1)) ? range.from : addDays(state.ctx.today, -1);
            if (from <= range.to) revalidate(from, range.to);
            return;
        }

        var key = range.from + '|' + range.to;
        if (state.pending === key) return;
        state.pending = key;
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnRequestData', [range.from, range.to]);
    }

    // Stale-while-revalidate: the click renders from cache instantly, this quietly re-requests the
    // same window so the capacity numbers catch up a moment later.
    function revalidate(from, to) {
        if (!state.ctx || !state.ctx.admissionCode) return;
        var key = from + '|' + to;
        if (state.pending === key || state.silentPending === key) return;
        state.silentPending = key;
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnRequestData', [from, to]);
    }

    function revalidateVisible() {
        var range = visibleRange();
        if (range) revalidate(range.from, range.to);
    }

    // ---------- BC entry points ----------

    window.SetContext = function (json) {
        var ctx = JSON.parse(json);
        var previousCode = state.ctx ? state.ctx.admissionCode : null;
        state.ctx = ctx;
        if (ctx.admissionCode !== previousCode) {
            // All cached slots belong to the previous admission. View and anchor survive on
            // purpose - switching admission while parked on a week compares the same dates.
            data.slotsByDate = Object.create(null);
            data.loadedDates.clear();
            state.silentPending = null;
            state.pending = null;
            state.selected = null;
            state.version++;
        }
        if (!state.anchor)
            state.anchor = ctx.today;
        refresh();
    };

    function selectAdmission(code) {
        if (state.ctx && code === state.ctx.admissionCode) return;
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnSelectAdmission', [code]);
    }

    window.SetCalendarData = function (json) {
        var payload = JSON.parse(json);
        for (var d = payload.fromDate; d <= payload.toDate; d = addDays(d, 1)) {
            delete data.slotsByDate[d];
            data.loadedDates.add(d);
        }
        (payload.slots || []).forEach(function (slot) {
            (data.slotsByDate[slot.startDate] = data.slotsByDate[slot.startDate] || []).push(slot);
        });
        // Only the answer to the request in flight clears it. A quiet answer or the day re-sent after a card toggle must not hide the pill.
        var key = payload.fromDate + '|' + payload.toDate;
        if (state.pending === key) state.pending = null;
        if (state.silentPending === key) state.silentPending = null;
        if (state.ctx && payload.today) {
            state.ctx.today = payload.today;
            state.ctx.nowTime = payload.nowTime;
        }
        state.version++;

        if (state.selected) {
            var selected = state.selected;
            var refreshed = null;
            var replacement = null;
            (data.slotsByDate[selected.startDate] || []).forEach(function (slot) {
                if (slot.entryNo === selected.entryNo) refreshed = slot;
                // The scheduler replaces a changed slot with a new Entry No. but keeps its External Schedule Entry No.
                else if (slot.externalEntryNo === selected.externalEntryNo) replacement = slot;
            });
            state.selected = refreshed || replacement;
        }
    };

    // ---------- slot helpers ----------

    function slotEndMinutes(slot) {
        if (slot.endDate && slot.endDate > slot.startDate) return 24 * 60;
        var end = toMinutes(slot.endTime);
        return (end === null) ? toMinutes(slot.startTime) + 30 : end;
    }

    function soldCount(slot) { return slot.initialEntryAll || 0; }
    function admittedCount(slot) { return slot.admitted || 0; }

    // Effective enterable window: an unset arrival edge falls back to the slot bound, exactly the way
    // GetAdmScheduleEntry resolves it at the gate. Empty when it coincides with the slot - the slot
    // times are already on show - so only a genuine divergence surfaces.
    function arrivalWindow(slot) {
        var from = timeSet(slot.arrivalFromTime) ? slot.arrivalFromTime : slot.startTime;
        var until = timeSet(slot.arrivalUntilTime) ? slot.arrivalUntilTime : slot.endTime;
        if (from === slot.startTime && until === slot.endTime) return '';
        return fmtTime(from) + ' – ' + fmtTime(until);
    }

    // A sell window may carry full dates (it can open days ahead) or be time-only on the slot's own day
    // - a blank date means "this day", the way the schedule's Sales From/Until do. dropDate omits a date
    // part that equals the slot's own day (the block form) and the year (both forms), keeping it legible.
    function salesWindow(slot, dropDate) {
        if (!slot.salesFromDate && !slot.salesUntilDate && !timeSet(slot.salesFromTime) && !timeSet(slot.salesUntilTime))
            return '';
        var opts = { day: 'numeric', month: 'short', year: dropDate ? undefined : 'numeric' };
        var edge = function (date, time) {
            var datePart = (date && !(dropDate && date === slot.startDate)) ? fmt(date, opts) + ' ' : '';
            var timePart = timeSet(time) ? fmtTime(time) : '';
            if (!datePart && !timePart) return '…';
            return datePart + timePart;
        };
        return edge(slot.salesFromDate, slot.salesFromTime) + ' – ' + edge(slot.salesUntilDate, slot.salesUntilTime);
    }

    // Which window bands a slot shows, in draw order (sales, then arrival). Drives both the band
    // geometry and how far the focused block narrows to make room for them - block + bands share the
    // day column, one column each, so nothing stacks in Z.
    function presentBands(slot) {
        var kinds = [];
        if (slot.salesFromDate || slot.salesUntilDate || timeSet(slot.salesFromTime) || timeSet(slot.salesUntilTime))
            kinds.push('sales');
        if (arrivalWindow(slot))
            kinds.push('arrival');
        return kinds;
    }

    // Admitted is measured against sold, not capacity: how many of the sold tickets have arrived.
    function formatAdmitted(slot, separator) {
        var sold = soldCount(slot);
        return sold > 0 ? admittedCount(slot) + separator + sold : String(admittedCount(slot));
    }

    function slotTip(slot) {
        var c = state.ctx.captions;
        var parts = [slot.scheduleCode, fmtTime(slot.startTime) + '–' + fmtTime(slot.endTime)];
        parts.push(slot.open ? c.open : c.closed);
        if (!slot.visibleOnWeb) parts.push(c.hiddenOnWeb);
        if (slot.unlimitedCapacity) {
            parts.push(c.sold + ' ' + soldCount(slot));
            parts.push(c.admitted + ' ' + formatAdmitted(slot, '/'));
        } else if (slot.maxCapacity > 0) {
            parts.push(c.sold + ' ' + soldCount(slot) + '/' + slot.maxCapacity);
            parts.push(c.admitted + ' ' + formatAdmitted(slot, '/'));
        }
        var aw = arrivalWindow(slot);
        if (aw) parts.push(c.arrivalWindow + ' ' + aw);
        var sw = salesWindow(slot, true);
        if (sw) parts.push(c.salesWindow + ' ' + sw);
        return parts.join(' · ');
    }

    function pct(value, max) {
        if (!max || max <= 0) return null;
        return Math.min(100, Math.round(value / max * 100));
    }

    // The track is the capacity. Sold, admitted and departed each fill it from the left, drawn in that
    // order, so each shows where it runs past the next.
    function barLayers(sold, admitted, departed, max) {
        if (pct(sold, max) === null) return null;
        var layer = function (value) { return { width: pct(value, max) + '%' }; };
        return { sold: layer(sold), admitted: layer(admitted), departed: layer(departed) };
    }

    // One visual state per slot; closed wins over hidden-on-web when both apply.
    function visualClass(slot) {
        if (!slot.open) return 'is-closed';
        if (!slot.visibleOnWeb) return 'is-hidden-web';
        return 'is-open';
    }

    function isPast(slot) {
        var ctx = state.ctx;
        if (!ctx) return false;
        if (slot.startDate < ctx.today) return true;
        if (slot.startDate > ctx.today) return false;
        return slotEndMinutes(slot) < toMinutes(ctx.nowTime);
    }

    // The Outlook algorithm: mutually overlapping slots form a cluster, each member takes the first
    // column that is free at its start, and every member of the cluster shares the cluster's width.
    function layoutDay(slots) {
        var events = slots.map(function (slot) {
            return { slot: slot, start: toMinutes(slot.startTime), end: slotEndMinutes(slot) };
        }).sort(function (a, b) { return (a.start - b.start) || (b.end - a.end); });

        var clusters = [];
        var cluster = null;
        var clusterEnd = -1;
        events.forEach(function (event) {
            if (!cluster || event.start >= clusterEnd) {
                cluster = { items: [] };
                clusters.push(cluster);
                clusterEnd = event.end;
            } else {
                clusterEnd = Math.max(clusterEnd, event.end);
            }
            cluster.items.push(event);
        });

        clusters.forEach(function (c) {
            var columnEnds = [];
            c.items.forEach(function (event) {
                var col = columnEnds.findIndex(function (end) { return end <= event.start; });
                if (col < 0) { col = columnEnds.length; columnEnds.push(0); }
                columnEnds[col] = event.end;
                event.col = col;
            });
            c.items.forEach(function (event) { event.colCount = columnEnds.length; });
        });

        return events;
    }

    // ---------- components ----------

    var CapacityBar = {
        props: ['item'],
        computed: {
            layers: function () {
                if (this.item.unlimitedCapacity) return null;
                return barLayers(soldCount(this.item), admittedCount(this.item), this.item.departed || 0, this.item.maxCapacity);
            },
            tip: function () {
                var c = state.ctx.captions;
                var tip = c.sold + ' ' + soldCount(this.item) + ' / ' + this.item.maxCapacity +
                    ' · ' + c.admitted + ' ' + formatAdmitted(this.item, ' / ');
                if (this.item.departed) tip += ' · ' + c.departed + ' ' + this.item.departed;
                return tip;
            }
        },
        template: '\
            <div v-if="layers" class="cap-bar" :title="tip">\
                <div class="cap-bar-sold" :style="layers.sold"></div>\
                <div class="cap-bar-admitted" :style="layers.admitted"></div>\
                <div class="cap-bar-departed" :style="layers.departed"></div>\
            </div>'
    };

    var SlotBlock = {
        props: ['event', 'dayStart'],
        components: { 'capacity-bar': CapacityBar },
        computed: {
            item: function () { return this.event.slot; },
            timeText: function () {
                if (this.density === 'roomy')
                    return fmtTime(this.item.startTime) + '–' + fmtTime(this.item.endTime);
                return fmtTime(this.item.startTime);
            },
            capText: function () {
                if (this.item.unlimitedCapacity) return String(soldCount(this.item));
                if (!this.item.maxCapacity || this.item.maxCapacity <= 0) return '';
                return soldCount(this.item) + '/' + this.item.maxCapacity;
            },
            chip: function () {
                var c = state.ctx.captions;
                if (!this.item.open) return { cls: 'chip-closed', text: c.closed };
                if (!this.item.visibleOnWeb) return { cls: 'chip-noweb', text: c.noWeb };
                return null;
            },
            tip: function () { return slotTip(this.item); },
            density: function () {
                // Thresholds are per fraction of the viewport, not per cluster column count -
                // a day-view column is seven times wider than a week-view one.
                var scale = (state.view === 'day') ? 7 : 1;
                if (this.event.colCount >= 7 * scale) return 'sliver';
                if (this.event.colCount >= 4 * scale) return 'compact';
                if (this.event.colCount >= 2 * scale) return 'full';
                return 'roomy';
            },
            classes: function () {
                var cls = ['slot-block', this.density, visualClass(this.item), isPast(this.item) ? 'is-past' : ''];
                if (state.view === 'day' && state.focused)
                    cls.push(state.focused.entryNo === this.item.entryNo ? 'is-focused' : 'is-dimmed');
                return cls;
            },
            style: function () {
                var gap = 2;
                var laneWidth = 100 / this.event.colCount;
                var left = this.event.col * laneWidth;
                var width = laneWidth;
                // While focused with bands, split this slot's own lane into (1 + bandCount) columns and
                // keep column 0; the bands take the rest. The block stays anchored at the lane's left and
                // only narrows - and in day view a stationary hit layer (not this block) drives hover, so
                // the block can shrink without ever sliding out from under the cursor.
                if (state.view === 'day' && state.focused && (state.focused.entryNo === this.item.entryNo)) {
                    var cols = 1 + presentBands(this.item).length;
                    if (cols > 1)
                        width = laneWidth / cols;
                }
                return {
                    top: ((this.event.start - this.dayStart) * HOUR_PX / 60) + 'px',
                    height: Math.max(18, (this.event.end - this.event.start) * HOUR_PX / 60 - gap) + 'px',
                    left: left + '%',
                    width: 'calc(' + width + '% - ' + gap + 'px)',
                    pointerEvents: (state.view === 'day') ? 'none' : 'auto'
                };
            }
        },
        methods: {
            select: function () {
                state.selected = this.item;
                revalidate(this.item.startDate, this.item.startDate);
            }
        },
        template: '\
            <div :class="classes" :style="style" @click.stop="select" :title="tip">\
                <div v-if="density !== \'sliver\'" class="slot-row">\
                    <span class="slot-time">{{ timeText }}</span>\
                    <span v-if="chip && density === \'roomy\'" class="slot-chip" :class="chip.cls">{{ chip.text }}</span>\
                    <span v-if="capText && (density === \'roomy\' || density === \'full\')" class="slot-cap">{{ capText }}</span>\
                </div>\
                <div v-if="density === \'roomy\' || density === \'full\'" class="slot-code">{{ item.scheduleCode }}</div>\
                <capacity-bar :item="item"></capacity-bar>\
            </div>'
    };

    var WeekView = {
        components: { 'slot-block': SlotBlock },
        computed: {
            dayCount: function () { return (state.view === 'day') ? 1 : 7; },
            gridColumns: function () { return '52px repeat(' + this.dayCount + ', 1fr)'; },
            days: function () {
                void state.version;
                var days = [];
                for (var i = 0; i < this.dayCount; i++) {
                    var date = addDays(state.anchor, i);
                    days.push({
                        date: date,
                        isToday: date === state.ctx.today,
                        events: layoutDay(data.slotsByDate[date] || [])
                    });
                }
                return days;
            },
            dayStartMinute: function () {
                var min = 24 * 60;
                this.days.forEach(function (day) {
                    day.events.forEach(function (e) { if (e.start < min) min = e.start; });
                });
                if (min === 24 * 60) min = 8 * 60;
                return Math.floor(min / 60) * 60 - GRID_PAD_MINUTES;
            },
            dayEndMinute: function () {
                var max = 0;
                this.days.forEach(function (day) {
                    day.events.forEach(function (e) { if (e.end > max) max = e.end; });
                });
                if (max === 0) max = 22 * 60;
                return Math.min(24 * 60, Math.ceil(max / 60) * 60);
            },
            hourMarks: function () {
                var out = [];
                var start = this.dayStartMinute;
                for (var m = Math.ceil(start / 60) * 60; m <= this.dayEndMinute; m += 60)
                    out.push({
                        minute: m,
                        top: (m - start) * HOUR_PX / 60,
                        label: (m < this.dayEndMinute) ? ('0' + (m / 60)).slice(-2) + ':00' : ''
                    });
                return out;
            },
            gridHeight: function () {
                return (this.dayEndMinute - this.dayStartMinute) * HOUR_PX / 60;
            },
            nowOffset: function () {
                var now = toMinutes(state.ctx.nowTime);
                if (now < this.dayStartMinute || now > this.dayEndMinute) return null;
                return (now - this.dayStartMinute) * HOUR_PX / 60;
            },
            isEmpty: function () {
                return this.days.every(function (day) { return day.events.length === 0; });
            }
        },
        methods: {
            dayLabel: function (date) { return fmt(date, { weekday: 'short' }); },
            dayNumber: function (date) { return fmt(date, { day: 'numeric' }); },
            openDay: function (date) {
                if (state.view === 'day') return;
                state.anchor = date;
                state.view = 'day';
                refresh();
            },
            // Sell (teal) and arrival (amber) windows of the hovered slot, drawn as bands over the
            // timeline in the slot's own lane - same col/colCount as its block, so an overlapping slot's
            // band is only as wide as the block it extends. Arrival uses the same slot-bound fallback as
            // the gate; sales can open a day early / close a day late, so its band clamps to this day.
            focusBands: function (day) {
                var slot = state.focused;
                if (state.view !== 'day' || !slot || slot.startDate !== day.date) return [];
                var kinds = presentBands(slot);
                if (!kinds.length) return [];
                var ev = null;
                for (var e = 0; e < day.events.length; e++)
                    if (day.events[e].slot.entryNo === slot.entryNo) { ev = day.events[e]; break; }
                if (!ev) return [];
                var top = this.dayStartMinute, bottom = this.dayEndMinute;
                // Split the focused slot's own lane into (1 + bandCount) columns; the block kept column 0,
                // the bands take the rest - side by side within the lane, nothing stacked in Z.
                var laneWidth = 100 / ev.colCount;
                var laneLeft = ev.col * laneWidth;
                var colWidth = laneWidth / (1 + kinds.length);
                var bands = [];
                kinds.forEach(function (kind, i) {
                    var fromMin, untilMin;
                    if (kind === 'sales') {
                        // A blank date means "this day", the way the schedule's Sales From/Until do;
                        // clamp a window that opens earlier / closes later to the visible day.
                        if (slot.salesFromDate && slot.salesFromDate > day.date) fromMin = bottom;
                        else if (slot.salesFromDate && slot.salesFromDate < day.date) fromMin = top;
                        else if (timeSet(slot.salesFromTime)) fromMin = toMinutes(slot.salesFromTime);
                        else fromMin = top;
                        if (slot.salesUntilDate && slot.salesUntilDate < day.date) untilMin = top;
                        else if (slot.salesUntilDate && slot.salesUntilDate > day.date) untilMin = bottom;
                        else if (timeSet(slot.salesUntilTime)) untilMin = toMinutes(slot.salesUntilTime);
                        else untilMin = bottom;
                    } else {
                        // Arrival falls an unset edge back to the slot bound, matching the gate.
                        fromMin = timeSet(slot.arrivalFromTime) ? toMinutes(slot.arrivalFromTime) : toMinutes(slot.startTime);
                        untilMin = timeSet(slot.arrivalUntilTime) ? toMinutes(slot.arrivalUntilTime) : slotEndMinutes(slot);
                    }
                    var fromLabel, untilLabel;
                    if (kind === 'sales') {
                        fromLabel = timeSet(slot.salesFromTime) ? fmtTime(slot.salesFromTime) : '';
                        untilLabel = timeSet(slot.salesUntilTime) ? fmtTime(slot.salesUntilTime) : '';
                    } else {
                        fromLabel = fmtTime(timeSet(slot.arrivalFromTime) ? slot.arrivalFromTime : slot.startTime);
                        untilLabel = fmtTime(timeSet(slot.arrivalUntilTime) ? slot.arrivalUntilTime : slot.endTime);
                    }
                    var a = Math.max(top, fromMin), b = Math.min(bottom, untilMin);
                    if (b > a) {
                        var height = (b - a) * HOUR_PX / 60;
                        bands.push({
                            kind: kind,
                            left: (laneLeft + (i + 1) * colWidth) + '%',
                            width: 'calc(' + colWidth + '% - 2px)',
                            top: (a - top) * HOUR_PX / 60,
                            height: height,
                            fromLabel: fromLabel,
                            untilLabel: untilLabel,
                            showTimes: height >= 26   // room for the from/until labels without them touching
                        });
                    }
                });
                return bands;
            },
            focusSlot: function (slot, on) {
                if (on) state.focused = slot;
                else if (state.focused && state.focused.entryNo === slot.entryNo) state.focused = null;
            },
            selectSlot: function (slot) {
                state.selected = slot;
                revalidate(slot.startDate, slot.startDate);
            },
            tipFor: function (slot) { return slotTip(slot); },
            // A stationary, transparent hit target at each slot's real lane rectangle (day view). It sits
            // above the blocks and bands and drives hover + click, so the focused block can shrink into its
            // column without sliding out from under the cursor - which was what made the hover thrash on the
            // middle/right slots of an overlap cluster.
            hitStyle: function (event) {
                var gap = 2, laneWidth = 100 / event.colCount;
                return {
                    top: ((event.start - this.dayStartMinute) * HOUR_PX / 60) + 'px',
                    height: Math.max(18, (event.end - event.start) * HOUR_PX / 60 - gap) + 'px',
                    left: (event.col * laneWidth) + '%',
                    width: 'calc(' + laneWidth + '% - ' + gap + 'px)'
                };
            }
        },
        template: '\
            <div class="week-view">\
                <div class="week-header" :style="{ gridTemplateColumns: gridColumns }">\
                    <div class="gutter-spacer"></div>\
                    <div v-for="day in days" :key="day.date" class="day-header" :class="{ \'is-today\': day.isToday }" @click="openDay(day.date)">\
                        <span class="day-name">{{ dayLabel(day.date) }}</span>\
                        <span class="day-number">{{ dayNumber(day.date) }}</span>\
                    </div>\
                </div>\
                <div class="week-scroll">\
                    <div class="week-grid" :style="{ height: gridHeight + \'px\', gridTemplateColumns: gridColumns }">\
                        <div class="time-gutter">\
                            <div v-for="mark in hourMarks" v-show="mark.label" :key="mark.minute" class="hour-label" :style="{ top: (mark.top - 6) + \'px\' }">{{ mark.label }}</div>\
                        </div>\
                        <div v-for="day in days" :key="day.date" class="day-column" :class="{ \'is-today\': day.isToday }">\
                            <div v-for="mark in hourMarks" :key="mark.minute" class="hour-line" :style="{ top: mark.top + \'px\' }"></div>\
                            <div v-if="day.isToday && nowOffset !== null" class="now-line" :style="{ top: nowOffset + \'px\' }"></div>\
                            <div v-for="band in focusBands(day)" :key="band.kind" class="window-band" :class="\'band-\' + band.kind" :style="{ top: band.top + \'px\', height: band.height + \'px\', left: band.left, width: band.width }">\
                                <span v-if="band.showTimes && band.fromLabel" class="band-time">{{ band.fromLabel }}</span>\
                                <span v-if="band.showTimes && band.untilLabel" class="band-time band-time-end">{{ band.untilLabel }}</span>\
                            </div>\
                            <slot-block v-for="event in day.events" :key="event.slot.entryNo" :event="event" :day-start="dayStartMinute"></slot-block>\
                            <template v-if="state.view === \'day\'">\
                                <div v-for="event in day.events" :key="\'hit\' + event.slot.entryNo" class="slot-hit" :style="hitStyle(event)" :title="tipFor(event.slot)" @click.stop="selectSlot(event.slot)" @mouseenter="focusSlot(event.slot, true)" @mouseleave="focusSlot(event.slot, false)"></div>\
                            </template>\
                        </div>\
                    </div>\
                    <div v-if="isEmpty" class="empty-hint">{{ state.ctx.captions.noSlots }}</div>\
                </div>\
            </div>',
        data: function () { return { state: state }; }
    };

    var MonthView = {
        computed: {
            cells: function () {
                void state.version;
                var first = monthStart(state.anchor);
                var gridStart = addDays(first, -dayOfWeek(first));
                var month = first.slice(0, 7);
                var cells = [];
                for (var i = 0; i < 42; i++) {
                    var date = addDays(gridStart, i);
                    var slots = data.slotsByDate[date] || [];
                    var sumMax = 0, sumSold = 0, sumAdmitted = 0, sumDeparted = 0, anyClosed = false, anyHidden = false;
                    slots.forEach(function (slot) {
                        if (!slot.unlimitedCapacity) {
                            sumMax += slot.maxCapacity || 0;
                            sumSold += soldCount(slot);
                            sumAdmitted += admittedCount(slot);
                            sumDeparted += slot.departed || 0;
                        }
                        if (!slot.open) anyClosed = true;
                        if (slot.open && !slot.visibleOnWeb) anyHidden = true;
                    });
                    cells.push({
                        date: date,
                        inMonth: date.slice(0, 7) === month,
                        isToday: date === state.ctx.today,
                        isPast: date < state.ctx.today,
                        count: slots.length,
                        soldPct: pct(sumSold, sumMax),
                        layers: barLayers(sumSold, sumAdmitted, sumDeparted, sumMax),
                        anyClosed: anyClosed,
                        anyHidden: anyHidden
                    });
                }
                return cells;
            },
            weekdayNames: function () {
                var names = [];
                for (var i = 0; i < 7; i++)
                    names.push(fmt(addDays(state.anchor, i - dayOfWeek(state.anchor)), { weekday: 'short' }));
                return names;
            }
        },
        methods: {
            openDay: function (cell) {
                state.anchor = cell.date;
                state.view = 'week';
                refresh();
            },
            dayNumber: function (date) { return +date.slice(8, 10); }
        },
        template: '\
            <div class="month-view">\
                <div class="month-weekdays">\
                    <div v-for="name in weekdayNames" :key="name" class="month-weekday">{{ name }}</div>\
                </div>\
                <div class="month-grid">\
                    <div v-for="cell in cells" :key="cell.date" class="month-cell"\
                         :class="{ \'out-month\': !cell.inMonth, \'is-today\': cell.isToday, \'is-past\': cell.isPast }"\
                         @click="cell.count && openDay(cell)">\
                        <div class="month-cell-top">\
                            <span class="month-day-number">{{ dayNumber(cell.date) }}</span>\
                            <span class="cell-dots">\
                                <span v-if="cell.anyHidden" class="hidden-dot" :title="state.ctx.captions.hiddenOnWeb"></span>\
                                <span v-if="cell.anyClosed" class="closed-dot" :title="state.ctx.captions.closed"></span>\
                            </span>\
                        </div>\
                        <template v-if="cell.count">\
                            <div class="month-count">{{ cell.count }} {{ state.ctx.captions.slots }}</div>\
                            <div v-if="cell.layers" class="cap-bar month-cap-bar">\
                                <div class="cap-bar-sold" :style="cell.layers.sold"></div>\
                                <div class="cap-bar-admitted" :style="cell.layers.admitted"></div>\
                                <div class="cap-bar-departed" :style="cell.layers.departed"></div>\
                            </div>\
                            <div v-if="cell.soldPct !== null" class="month-pct">{{ cell.soldPct }}%</div>\
                        </template>\
                    </div>\
                </div>\
            </div>',
        data: function () { return { state: state }; }
    };

    var YearView = {
        computed: {
            months: function () {
                var yearFirst = state.anchor.slice(0, 4) + '-01-01';
                var todayMonth = monthStart(state.ctx.today);
                var months = [];
                for (var i = 0; i < 12; i++) {
                    var first = addMonths(yearFirst, i);
                    var next = addMonths(first, 1);
                    var cells = [];
                    for (var lead = 0; lead < dayOfWeek(first); lead++)
                        cells.push(null);
                    for (var d = first; d < next; d = addDays(d, 1))
                        cells.push({ date: d, isToday: d === state.ctx.today });
                    months.push({
                        first: first,
                        name: fmt(first, { month: 'long' }),
                        isCurrent: first === todayMonth,
                        days: cells
                    });
                }
                return months;
            },
            weekdayInitials: function () {
                var names = [];
                for (var i = 0; i < 7; i++)
                    names.push(fmt(addDays(state.anchor, i - dayOfWeek(state.anchor)), { weekday: 'narrow' }));
                return names;
            }
        },
        methods: {
            openMonth: function (date) {
                state.anchor = date;
                state.view = 'month';
                refresh();
            }
        },
        template: '\
            <div class="year-view">\
                <div v-for="month in months" :key="month.first" class="year-month" :class="{ \'is-current\': month.isCurrent }" @click="openMonth(month.first)">\
                    <div class="year-month-name">{{ month.name }}</div>\
                    <div class="year-month-grid">\
                        <span v-for="(initial, idx) in weekdayInitials" :key="\'w\' + idx" class="year-weekday">{{ initial }}</span>\
                        <span v-for="(day, idx) in month.days" :key="\'d\' + idx" class="year-day" :class="{ \'is-today\': day && day.isToday, \'is-blank\': !day }">{{ day ? +day.date.slice(8, 10) : \'\' }}</span>\
                    </div>\
                </div>\
            </div>'
    };

    var DetailCard = {
        computed: {
            item: function () { return state.selected; },
            c: function () { return state.ctx.captions; },
            visual: function () { return visualClass(this.item); },
            soldPct: function () { return this.item.unlimitedCapacity ? null : pct(soldCount(this.item), this.item.maxCapacity); },
            // Walk-ins can take admitted past 100% of sold, which is worth showing.
            admittedPct: function () { return this.sold > 0 ? Math.round(this.admitted / this.sold * 100) : null; },
            layers: function () {
                if (this.item.unlimitedCapacity) return null;
                return barLayers(this.sold, this.admitted, this.item.departed || 0, this.item.maxCapacity);
            },
            sold: function () { return soldCount(this.item); },
            admitted: function () { return admittedCount(this.item); },
            hasCeiling: function () { return !this.item.unlimitedCapacity && this.item.maxCapacity > 0; },
            soldText: function () { return this.hasCeiling ? this.sold + ' / ' + this.item.maxCapacity : String(this.sold); },
            admittedText: function () { return formatAdmitted(this.item, ' / '); },
            startText: function () {
                return fmt(this.item.startDate, { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' }) +
                    ' · ' + fmtTime(this.item.startTime) + ' – ' + fmtTime(this.item.endTime);
            },
            arrivalText: function () { return arrivalWindow(this.item); },
            salesText: function () { return salesWindow(this.item, false); }
        },
        methods: {
            close: function () { state.selected = null; },
            toggle: function (fieldName, newValue) {
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnToggleSlotField', [this.item.entryNo, fieldName, newValue]);
            }
        },
        template: '\
            <div class="card-backdrop" @click.self="close">\
                <div class="detail-card">\
                    <div class="card-head" :class="visual">\
                        <div>\
                            <div class="card-title">{{ item.scheduleCode }}</div>\
                            <div class="card-subtitle">{{ startText }}</div>\
                        </div>\
                        <button class="card-close" @click="close">×</button>\
                    </div>\
                    <div class="card-toggles">\
                        <button class="state-pill" :class="item.open ? \'is-open\' : \'is-closed\'" @click="toggle(\'open\', !item.open)">\
                            {{ item.open ? c.open : c.closed }}<span class="pill-flip">&#8644;</span>\
                        </button>\
                        <button class="state-pill" :class="item.visibleOnWeb ? \'is-visible\' : \'is-hidden-web\'" @click="toggle(\'visibleOnWeb\', !item.visibleOnWeb)">\
                            {{ item.visibleOnWeb ? c.visibleOnWeb : c.hiddenOnWeb }}<span class="pill-flip">&#8644;</span>\
                        </button>\
                        <span v-if="item.priceProfileCode" class="badge badge-muted">{{ c.priceProfile }}: {{ item.priceProfileCode }}</span>\
                    </div>\
                    <div class="card-capacity">\
                        <div class="card-cap-line"><span>{{ c.sold }}</span><strong>{{ soldText }}</strong><em v-if="soldPct !== null">{{ soldPct }}%</em></div>\
                        <div class="card-cap-line"><span>{{ c.admitted }}</span><strong>{{ admittedText }}</strong><em v-if="admittedPct !== null">{{ admittedPct }}%</em></div>\
                        <div v-if="item.departed" class="card-cap-line"><span>{{ c.departed }}</span><strong>{{ item.departed }}</strong></div>\
                        <div v-if="layers" class="cap-bar card-cap-bar">\
                            <div class="cap-bar-sold" :style="layers.sold"></div>\
                            <div class="cap-bar-admitted" :style="layers.admitted"></div>\
                            <div class="cap-bar-departed" :style="layers.departed"></div>\
                        </div>\
                    </div>\
                    <div class="card-grid">\
                        <div class="card-row" v-if="hasCeiling"><span>{{ c.maxCapacity }}</span><strong>{{ item.maxCapacity }}</strong></div>\
                        <div class="card-row" v-if="item.capacityControlText"><span>{{ c.capacity }}</span><strong>{{ item.capacityControlText }}</strong></div>\
                        <div class="card-row"><span>{{ c.duration }}</span><strong>{{ item.durationText }}</strong></div>\
                        <div class="card-row" v-if="arrivalText"><span>{{ c.arrivalWindow }}</span><strong>{{ arrivalText }}</strong></div>\
                        <div class="card-row" v-if="salesText"><span>{{ c.salesWindow }}</span><strong>{{ salesText }}</strong></div>\
                        <div class="card-row"><span>{{ c.allocationBy }}</span><strong>{{ item.allocationBy }}</strong></div>\
                        <div class="card-row" v-if="item.waitingListQueue"><span>{{ c.waitingListQueue }}</span><strong>{{ item.waitingListQueue }}</strong></div>\
                        <div class="card-row"><span>{{ c.entryNo }}</span><strong>{{ item.entryNo }}</strong></div>\
                        <div class="card-row"><span>{{ c.externalEntryNo }}</span><strong>{{ item.externalEntryNo }}</strong></div>\
                    </div>\
                </div>\
            </div>'
    };

    var AdmissionPicker = {
        data: function () {
            return { open: false, filter: '', state: state };
        },
        computed: {
            filtered: function () {
                var needle = this.filter.toLowerCase();
                return (state.ctx.admissions || []).filter(function (admission) {
                    if (!needle) return true;
                    return (admission.code + ' ' + admission.description).toLowerCase().indexOf(needle) >= 0;
                });
            }
        },
        methods: {
            toggle: function () {
                this.open = !this.open;
                this.filter = '';
                if (this.open) {
                    var self = this;
                    Vue.nextTick(function () { if (self.$refs.filterInput) self.$refs.filterInput.focus(); });
                }
            },
            pick: function (admission) {
                this.open = false;
                selectAdmission(admission.code);
            }
        },
        template: '\
            <div class="adm-picker">\
                <button class="adm-picker-btn" @click="toggle()">\
                    <span class="adm-code">{{ state.ctx.admissionCode }}</span>\
                    <span class="adm-desc">{{ state.ctx.admissionDescription }}</span>\
                    <span class="adm-chevron">▾</span>\
                </button>\
                <div v-if="open" class="picker-backdrop" @click="open = false"></div>\
                <div v-if="open" class="picker-panel">\
                    <input class="picker-filter" v-model="filter" :placeholder="state.ctx.captions.filterAdmissions" @keydown.esc.stop="open = false" ref="filterInput">\
                    <div class="picker-list">\
                        <div v-for="admission in filtered" :key="admission.code" class="picker-item" :class="{ active: admission.code === state.ctx.admissionCode }" @click="pick(admission)">\
                            <span class="picker-code">{{ admission.code }}</span>\
                            <span class="picker-desc">{{ admission.description }}</span>\
                        </div>\
                    </div>\
                </div>\
            </div>'
    };

    var CalendarApp = {
        components: { 'week-view': WeekView, 'month-view': MonthView, 'year-view': YearView, 'detail-card': DetailCard, 'admission-picker': AdmissionPicker },
        computed: {
            state: function () { return state; },
            title: function () {
                if (state.view === 'year')
                    return state.anchor.slice(0, 4);
                if (state.view === 'month')
                    return fmt(monthStart(state.anchor), { month: 'long', year: 'numeric' });
                if (state.view === 'day')
                    return fmt(state.anchor, { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
                var from = state.anchor;
                var to = addDays(state.anchor, 6);
                return fmt(from, { day: 'numeric', month: 'short' }) + ' – ' +
                    fmt(to, { day: 'numeric', month: 'short', year: 'numeric' });
            },
            loading: function () { return state.pending !== null; }
        },
        methods: {
            pickAdmission: function (code) { selectAdmission(code); },
            refreshVisible: function () { revalidateVisible(); },
            go: function (direction) {
                if (state.view === 'day')
                    state.anchor = addDays(state.anchor, direction);
                else if (state.view === 'week')
                    state.anchor = addDays(state.anchor, direction * 7);
                else if (state.view === 'month')
                    state.anchor = addMonths(state.anchor, direction);
                else
                    state.anchor = addMonths(state.anchor, direction * 12);
                refresh();
            },
            goToday: function () {
                state.anchor = state.ctx.today;
                refresh();
            },
            setView: function (view) {
                if (state.view === view) return;
                state.view = view;
                if ((view === 'week' || view === 'day') && (state.anchor < state.ctx.today) && (monthStart(state.anchor) === monthStart(state.ctx.today)))
                    state.anchor = state.ctx.today;
                refresh();
            }
        },
        mounted: function () {
            var self = this;
            window.addEventListener('keydown', function (keyEvent) {
                if (!state.ctx || !state.ctx.admissionCode) return;
                if (keyEvent.target && keyEvent.target.tagName === 'INPUT') return;
                if (keyEvent.key === 'Escape') state.selected = null;
                if (keyEvent.key === 'ArrowLeft') self.go(-1);
                if (keyEvent.key === 'ArrowRight') self.go(1);
            });
        },
        template: '\
            <div class="cal-app" v-if="state.ctx">\
                <div class="nav-bar">\
                    <div class="nav-right">\
                        <div class="view-toggle">\
                            <button :class="{ active: state.view === \'day\' }" @click="setView(\'day\')">{{ state.ctx.captions.day }}</button>\
                            <button :class="{ active: state.view === \'week\' }" @click="setView(\'week\')">{{ state.ctx.captions.week }}</button>\
                            <button :class="{ active: state.view === \'month\' }" @click="setView(\'month\')">{{ state.ctx.captions.month }}</button>\
                            <button :class="{ active: state.view === \'year\' }" @click="setView(\'year\')">{{ state.ctx.captions.year }}</button>\
                        </div>\
                    </div>\
                    <div class="nav-center">\
                        <button class="nav-btn" @click="go(-1)" aria-label="previous">‹</button>\
                        <button class="nav-btn nav-today" @click="goToday()">{{ state.ctx.captions.today }}</button>\
                        <button class="nav-btn" @click="go(1)" aria-label="next">›</button>\
                        <button v-if="state.view !== \'year\'" class="nav-btn nav-refresh" :class="{ spinning: state.silentPending !== null }" @click="refreshVisible()" :title="state.ctx.captions.refresh" :aria-label="state.ctx.captions.refresh">\
                            <svg viewBox="0 0 16 16" aria-hidden="true"><path d="M13.5 8a5.5 5.5 0 1 1-1.61-3.89" /><path d="M13.5 2.5v3h-3" /></svg>\
                        </button>\
                        <span class="nav-title">{{ title }}</span>\
                    </div>\
                    <div class="nav-left">\
                        <admission-picker v-if="state.ctx.admissionCode"></admission-picker>\
                    </div>\
                </div>\
                <div class="cal-body">\
                    <week-view v-if="state.view === \'week\' || state.view === \'day\'"></week-view>\
                    <month-view v-else-if="state.view === \'month\'"></month-view>\
                    <year-view v-else></year-view>\
                    <div v-if="loading" class="loading-pill">{{ state.ctx.captions.loading }}</div>\
                </div>\
                <detail-card v-if="state.selected"></detail-card>\
                <div v-if="!state.ctx.admissionCode" class="card-backdrop">\
                    <div class="detail-card admission-modal">\
                        <div class="card-head">\
                            <div><div class="card-title">{{ state.ctx.captions.selectAdmission }}</div></div>\
                        </div>\
                        <div v-if="!state.ctx.admissions || !state.ctx.admissions.length" class="modal-empty">{{ state.ctx.captions.noAdmissions }}</div>\
                        <div v-else class="landing-list">\
                            <div class="landing-row landing-head">\
                                <span>{{ state.ctx.captions.admission }}</span>\
                                <span>{{ state.ctx.captions.description }}</span>\
                                <span>{{ state.ctx.captions.type }}</span>\
                            </div>\
                            <div v-for="admission in state.ctx.admissions" :key="admission.code" class="landing-row" @click="pickAdmission(admission.code)">\
                                <span class="landing-code">{{ admission.code }}</span>\
                                <span class="landing-desc">{{ admission.description }}</span>\
                                <span class="landing-type">{{ admission.typeText }}</span>\
                            </div>\
                        </div>\
                    </div>\
                </div>\
            </div>\
            <div class="cal-app cal-waiting" v-else></div>'
    };

    window.NPRAdmissionCalendar = {
        mount: function (selector) {
            return Vue.createApp(CalendarApp).mount(selector);
        }
    };
})();
