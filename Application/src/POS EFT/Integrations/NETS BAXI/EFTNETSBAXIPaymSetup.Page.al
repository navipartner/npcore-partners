page 6184509 "NPR EFT NETS BAXI Paym. Setup"
{

    Caption = 'EFT NETS BAXI Payment Setup';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR EFT NETS BAXI Paym. Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Log File Path"; Rec."Log File Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log File Path field';
                }
                field("Trace Level"; Rec."Trace Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trace Level field';
                }
                field("Baud Rate"; Rec."Baud Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Baud Rate field';
                }
                field("COM Port"; Rec."COM Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the COM Port field';
                }
                field("Host Environment"; Rec."Host Environment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Host Environment field';
                }
                field("Cutter Support"; Rec."Cutter Support")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cutter Support field';
                }
                field("Printer Width"; Rec."Printer Width")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Printer Width field';
                }
                field("Display Width"; Rec."Display Width")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Display Width field';
                }
                field("Log Auto Delete Days"; Rec."Log Auto Delete Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Auto Delete Days field';
                }
                field("Socket Listener"; Rec."Socket Listener")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Socket Listener field';
                }
                field("Socket Listener Port"; Rec."Socket Listener Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Socket Listener Port field';
                }
                field("Bluetooth Tunnel"; Rec."Bluetooth Tunnel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bluetooth Tunnel field';
                }
                field("Link Control Timeout Seconds"; Rec."Link Control Timeout Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Link Control Timeout Seconds field';
                }
                field(DCC; Rec.DCC)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the DCC field';
                }
                field("Force Offline"; Rec."Force Offline")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Force Offline field';
                }
                field("Auto Reconcile On EOD"; Rec."Auto Reconcile On EOD")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Reconcile On EOD field';
                }
                field("Force Abort Minimum Seconds"; Rec."Force Abort Minimum Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Force Abort Minimum Seconds field';
                }
                field("Administration Timeout Seconds"; Rec."Administration Timeout Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Administration Timeout Seconds field';
                }
                field("Lookup Timeout Seconds"; Rec."Lookup Timeout Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lookup Timeout Seconds field';
                }
                field("Open Timeout Seconds"; Rec."Open Timeout Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open Timeout Seconds field';
                }
                field("Close Timeout Seconds"; Rec."Close Timeout Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Close Timeout Seconds field';
                }
            }
        }
    }

    actions
    {
    }
}

