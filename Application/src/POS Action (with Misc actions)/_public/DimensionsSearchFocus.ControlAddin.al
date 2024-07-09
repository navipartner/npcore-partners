#IF NOT BC17
controladdin "NPR Dimensions SearchFocus"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Auto setting focus on fields is not supported. If requested, please inform the customer how BC works and where the MS idea portal is if they wish the behaviour was different. See case 580270.';

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

    [Obsolete('The control add-in has been removed. See case 580270.', '2023-06-28')]
    event SearchDimensions()
    [Obsolete('The control add-in has been removed. See case 580270.', '2023-06-28')]
    procedure SetFocusOnField(FieldNo: Text)
    [Obsolete('The control add-in has been removed. See case 580270.', '2023-06-28')]
    procedure SetFocusOnFieldPhone(FieldNo: Text)
}
#ENDIF
