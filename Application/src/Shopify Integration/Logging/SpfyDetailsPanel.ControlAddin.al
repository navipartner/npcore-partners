controladdin "NPR Spfy Details Panel"
{
    RequestedHeight = 620;
    MinimumHeight = 300;
    RequestedWidth = 340;
    MinimumWidth = 260;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;

    Scripts = 'Resources/DetailsPanel/main.js';
    StartupScript = 'Resources/DetailsPanel/start.js';
    StyleSheets = 'Resources/DetailsPanel/main.css';

    //  BC -> JS
    procedure SetLabels(LabelsJson: Text);
    procedure SetDetails(DetailsJson: Text);
    procedure Clear();

    //  JS -> BC
    event ControlReady();
    event RetryClicked();
    event ShowErrorClicked();
    event ExternalNoClicked();
    event OrderHistoryClicked();
}
