controladdin "NPR Dimensions SearchFocus"
{
    Scripts = '.scripts/focusSearchBox.js';
    RequestedHeight = 1;
    MinimumHeight = 1;
    MaximumHeight = 1;
    RequestedWidth = 1;
    MinimumWidth = 1;
    MaximumWidth = 1;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;

    event SearchDimensions()
    procedure SetFocusOnField(FieldNo: Text)
    procedure SetFocusOnFieldPhone(FieldNo: Text)
}