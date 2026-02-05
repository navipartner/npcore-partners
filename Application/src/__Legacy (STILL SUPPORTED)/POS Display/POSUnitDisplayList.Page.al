page 6060004 "NPR POS Unit Display"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    SourceTable = "NPR POS Unit Display";
    Caption = 'POS Unit Display';
#IF NOT BC17
    AboutTitle = 'Unit Display';
    AboutText = 'This page is where device specific information of a profile display can be set. Like if a specific POS Unit has downloaded the media or which screen should be used';
#ENDIF
    Extensible = False;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("POS Unit No."; Rec.POSUnit)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the number of the POS unit you want to configure.';
#IF NOT BC17
                    AboutTitle = 'POS Unit No.';
                    AboutText = 'Specifies the number of the POS unit you want to configure.';
#ENDIF
                }
                field("MediaDownloaded"; Rec."Media Downloaded")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the device occupying the provided POS Unit No. has downloaded the media. Disable if media should be downloaded again.';
#IF NOT BC17
                    AboutTitle = 'Media Downloaded';
                    AboutText = 'Specifies whether the device occupying the provided POS Unit No. has downloaded the media. Disable if media should be downloaded again.';
#ENDIF
                }
                field("Screen No."; Rec."Screen No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies which screen the customer display should occupy. 0 is the default value, and in most cases the secondary screen is selected if only two screens are connected to the device.';
#IF NOT BC17
                    AboutTitle = 'Screen number';
                    AboutText = 'Here you can specify which screen the costummer display should be displayed on. 0 is the default value, and in most cases select the secondary screen if only two screens are connected to the device.';
#ENDIF
                }
            }
        }
    }
}