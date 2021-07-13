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

                    ToolTip = 'Specifies the value of the Log File Path field';
                    ApplicationArea = NPRRetail;
                }
                field("Trace Level"; Rec."Trace Level")
                {

                    ToolTip = 'Specifies the value of the Trace Level field';
                    ApplicationArea = NPRRetail;
                }
                field("Baud Rate"; Rec."Baud Rate")
                {

                    ToolTip = 'Specifies the value of the Baud Rate field';
                    ApplicationArea = NPRRetail;
                }
                field("COM Port"; Rec."COM Port")
                {

                    ToolTip = 'Specifies the value of the COM Port field';
                    ApplicationArea = NPRRetail;
                }
                field("Host Environment"; Rec."Host Environment")
                {

                    ToolTip = 'Specifies the value of the Host Environment field';
                    ApplicationArea = NPRRetail;
                }
                field("Cutter Support"; Rec."Cutter Support")
                {

                    ToolTip = 'Specifies the value of the Cutter Support field';
                    ApplicationArea = NPRRetail;
                }
                field("Printer Width"; Rec."Printer Width")
                {

                    ToolTip = 'Specifies the value of the Printer Width field';
                    ApplicationArea = NPRRetail;
                }
                field("Display Width"; Rec."Display Width")
                {

                    ToolTip = 'Specifies the value of the Display Width field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Auto Delete Days"; Rec."Log Auto Delete Days")
                {

                    ToolTip = 'Specifies the value of the Log Auto Delete Days field';
                    ApplicationArea = NPRRetail;
                }
                field("Socket Listener"; Rec."Socket Listener")
                {

                    ToolTip = 'Specifies the value of the Socket Listener field';
                    ApplicationArea = NPRRetail;
                }
                field("Socket Listener Port"; Rec."Socket Listener Port")
                {

                    ToolTip = 'Specifies the value of the Socket Listener Port field';
                    ApplicationArea = NPRRetail;
                }
                field("Bluetooth Tunnel"; Rec."Bluetooth Tunnel")
                {

                    ToolTip = 'Specifies the value of the Bluetooth Tunnel field';
                    ApplicationArea = NPRRetail;
                }
                field("Link Control Timeout Seconds"; Rec."Link Control Timeout Seconds")
                {

                    ToolTip = 'Specifies the value of the Link Control Timeout Seconds field';
                    ApplicationArea = NPRRetail;
                }
                field(DCC; Rec.DCC)
                {

                    ToolTip = 'Specifies the value of the DCC field';
                    ApplicationArea = NPRRetail;
                }
                field("Force Offline"; Rec."Force Offline")
                {

                    ToolTip = 'Specifies the value of the Force Offline field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Reconcile On EOD"; Rec."Auto Reconcile On EOD")
                {

                    ToolTip = 'Specifies the value of the Auto Reconcile On EOD field';
                    ApplicationArea = NPRRetail;
                }
                field("Force Abort Minimum Seconds"; Rec."Force Abort Minimum Seconds")
                {

                    ToolTip = 'Specifies the value of the Force Abort Minimum Seconds field';
                    ApplicationArea = NPRRetail;
                }
                field("Administration Timeout Seconds"; Rec."Administration Timeout Seconds")
                {

                    ToolTip = 'Specifies the value of the Administration Timeout Seconds field';
                    ApplicationArea = NPRRetail;
                }
                field("Lookup Timeout Seconds"; Rec."Lookup Timeout Seconds")
                {

                    ToolTip = 'Specifies the value of the Lookup Timeout Seconds field';
                    ApplicationArea = NPRRetail;
                }
                field("Open Timeout Seconds"; Rec."Open Timeout Seconds")
                {

                    ToolTip = 'Specifies the value of the Open Timeout Seconds field';
                    ApplicationArea = NPRRetail;
                }
                field("Close Timeout Seconds"; Rec."Close Timeout Seconds")
                {

                    ToolTip = 'Specifies the value of the Close Timeout Seconds field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

