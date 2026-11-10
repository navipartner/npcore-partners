controladdin "NPR TMAdmissionCalendar"
{
    Scripts =
        'src/_ControlAddIns/TicketModule/Scripts/vue_global_prod.js',
        'src/_ControlAddIns/TicketModule/Scripts/admissionCalendar.js';

    StartupScript = 'src/_ControlAddIns/TicketModule/Scripts/startup.js';

    StyleSheets = 'src/_ControlAddIns/TicketModule/Stylesheets/admissionCalendar.css';

    RequestedHeight = 800;
    MinimumHeight = 400;
    MinimumWidth = 700;

    HorizontalStretch = true;
    VerticalStretch = true;
    HorizontalShrink = true;
    VerticalShrink = true;

    event OnControlReady();
    event OnRequestData(FromDate: Text; ToDate: Text);
    event OnToggleSlotField(EntryNo: Integer; FieldName: Text; NewValue: Boolean);
    event OnSelectAdmission(AdmissionCode: Text);

    procedure SetContext(ContextJson: Text);
    procedure SetCalendarData(PayloadJson: Text);
}
