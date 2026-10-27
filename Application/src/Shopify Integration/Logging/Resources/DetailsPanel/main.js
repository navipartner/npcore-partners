var NprSpfyDetails = (function () {
    'use strict';

    var labels = {};

    function invoke(method, args, onDone) {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(method, args || [], false, onDone, onDone);
    }

    function esc(text) {
        var d = document.createElement('div');
        d.textContent = (text === null || text === undefined) ? '' : String(text);
        return d.innerHTML;
    }

    function label(key) {
        var value = labels[key];
        return (value === null || value === undefined) ? '' : String(value);
    }

    //  Fills %1, %2, ... of an AL label template.
    function fmt(template) {
        var args = arguments;
        return String(template).replace(/%(\d)/g, function (match, n) {
            var value = args[Number(n)];
            return (value === null || value === undefined) ? '' : String(value);
        });
    }

    function row(caption, value, action) {
        if (value === null || value === undefined || value === '') { return ''; }
        var valueHtml = action
            ? '<button type="button" class="npr-row__value npr-link" data-action="' + esc(action) + '">' + esc(value) + '</button>'
            : '<span class="npr-row__value">' + esc(value) + '</span>';
        return '<div class="npr-row">' +
            '<span class="npr-row__label">' + esc(caption) + '</span>' +
            valueHtml +
            '</div>';
    }

    function step(s, isLast, nextDone) {
        var icon = s.state === 'done' ? '\u2713' : (s.state === 'failed' ? '\u2715' : '');
        var tag = s.tag === 'virtual' ? label('tagVirtual') : '';

        return '<div class="npr-step npr-step--' + esc(s.state) + '">' +
            '<div class="npr-step__rail">' +
            '<span class="npr-step__marker">' + icon + '</span>' +
            (isLast ? '' : '<span class="npr-step__line' + (nextDone ? ' npr-step__line--done' : '') + '"></span>') +
            '</div>' +
            '<div class="npr-step__body">' +
            '<div class="npr-step__head">' +
            '<span class="npr-step__label">' + esc(s.label) + '</span>' +
            (tag ? '<span class="npr-step__tag">' + esc(tag) + '</span>' : '') +
            '</div>' +
            (s.detail ? '<div class="npr-step__detail">' + esc(s.detail) + '</div>' : '') +
            '</div>' +
            '</div>';
    }

    function logCard(d) {
        if (!d.hasError && !d.isPostponed) {
            return d.errorMessage ? '<div class="npr-info">' + esc(d.errorMessage) + '</div>' : '';
        }

        var meta = [];
        if (d.errorAt) { meta.push(esc(fmt(label('lastError'), d.errorAt))); }
        if (d.maxRetries > 0) { meta.push(esc(fmt(label('retries'), d.retries, d.maxRetries))); }

        var exhausted = d.hasError && d.maxRetries > 0 && d.retries >= d.maxRetries;
        var cardClass = 'npr-error' +
            (d.hasError ? '' : ' npr-error--postponed') +
            (exhausted ? ' npr-error--exhausted' : '');

        return '<div class="' + cardClass + '">' +
            '<div class="npr-error__label">' + esc(label(d.hasError ? 'errorCardTitle' : 'postponedCardTitle')) + '</div>' +
            (d.errorMessage ? '<div class="npr-error__msg">' + esc(d.errorMessage) + '</div>' : '') +
            (meta.length ? '<div class="npr-error__meta">' + meta.join(' \u00b7 ') + '</div>' : '') +
            '<div class="npr-error__actions">' +
            '<button type="button" class="npr-btn npr-btn--primary" data-action="RetryClicked">' + esc(label('retryButton')) + '</button>' +
            (d.errorMessage ? '<button type="button" class="npr-btn" data-action="ShowErrorClicked">' + esc(label('showErrorButton')) + '</button>' : '') +
            '</div>' +
            '</div>';
    }

    function ecomCard(d) {
        if (!d.ecomError) { return ''; }

        return '<div class="npr-error">' +
            '<div class="npr-error__label">' + esc(label('ecomErrorCardTitle')) + '</div>' +
            '<div class="npr-error__msg npr-error__msg--multiline">' + esc(d.ecomError) + '</div>' +
            '<div class="npr-error__actions">' +
            '<button type="button" class="npr-link" data-action="ExternalNoClicked">' + esc(label('openEcomDocument')) + '</button>' +
            '</div>' +
            '</div>';
    }

    function section(title, body) {
        if (!body) { return ''; }
        return '<div class="npr-section">' +
            '<div class="npr-section__title">' + esc(title) + '</div>' +
            body +
            '</div>';
    }

    function render(d) {
        var host = document.getElementById('controlAddIn');
        if (!host) { return; }

        var documentRows =
            row(label('documentName'), d.documentName) +
            row(label('storeCode'), d.storeCode) +
            row(label('externalNo'), d.externalNo, 'ExternalNoClicked') +
            row(label('eventDate'), d.eventDate) +
            row(label('closedAt'), d.closedAt) +
            row(label('cancelledAt'), d.cancelledAt) +
            row(label('amountSCY'), d.amountSCY) +
            row(label('amountLCY'), d.amountLCY);

        if (d.orderEventCount > 0) {
            documentRows += row(label('orderHistory'), fmt(label('orderEventPosition'), d.orderEventIndex, d.orderEventCount), 'OrderHistoryClicked');
        }

        var pipeline = '';
        if (d.steps && d.steps.length) {
            pipeline = '<div class="npr-pipeline">';
            d.steps.forEach(function (s, i) {
                var next = d.steps[i + 1];
                pipeline += step(s, !next, next && next.state === 'done');
            });
            pipeline += '</div>';
        }

        host.innerHTML =
            '<div class="npr-panel">' +
            '<div class="npr-panel__head">' + esc(fmt(label('panelTitle'), d.entryNo)) + '</div>' +
            logCard(d) +
            ecomCard(d) +
            section(label('documentSection'), documentRows) +
            section(label('pipelineSection'), pipeline) +
            '</div>';

        Array.prototype.forEach.call(host.querySelectorAll('[data-action]'), function (el) {
            el.addEventListener('click', function () {
                if (el.disabled) { return; }
                el.disabled = true;
                invoke(el.getAttribute('data-action'), [], function () {
                    el.disabled = false;
                });
            });
        });
    }

    function showMessage(key) {
        var host = document.getElementById('controlAddIn');
        if (host) { host.innerHTML = '<div class="npr-empty">' + esc(label(key)) + '</div>'; }
    }

    return {
        init: function () {
            invoke('ControlReady');
        },

        setLabels: function (json) {
            try {
                labels = JSON.parse(json) || {};
            } catch (e) {
                labels = {};
            }
        },

        setDetails: function (json) {
            try {
                render(JSON.parse(json));
            } catch (e) {
                showMessage('loadError');
            }
        },

        clear: function () {
            showMessage('emptyPanel');
        }
    };
})();

function SetLabels(json) {
    NprSpfyDetails.setLabels(json);
}

function SetDetails(json) {
    NprSpfyDetails.setDetails(json);
}

function Clear() {
    NprSpfyDetails.clear();
}
