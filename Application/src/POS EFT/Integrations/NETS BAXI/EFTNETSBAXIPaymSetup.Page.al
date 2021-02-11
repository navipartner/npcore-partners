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
                field("Log File Path"; "Log File Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log File Path field';
                }
                field("Trace Level"; "Trace Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trace Level field';
                }
                field("Baud Rate"; "Baud Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Baud Rate field';
                }
                field("COM Port"; "COM Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the COM Port field';
                }
                field("Host Environment"; "Host Environment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Host Environment field';
                }
                field("Cutter Support"; "Cutter Support")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cutter Support field';
                }
                field("Printer Width"; "Printer Width")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Printer Width field';
                }
                field("Display Width"; "Display Width")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Display Width field';
                }
                field("Log Auto Delete Days"; "Log Auto Delete Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Auto Delete Days field';
                }
                field("Socket Listener"; "Socket Listener")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Socket Listener field';
                }
                field("Socket Listener Port"; "Socket Listener Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Socket Listener Port field';
                }
                field("Bluetooth Tunnel"; "Bluetooth Tunnel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bluetooth Tunnel field';
                }
                field("Link Control Timeout Seconds"; "Link Control Timeout Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Link Control Timeout Seconds field';
                }
                field(DCC; DCC)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the DCC field';
                }
                field("Force Offline"; "Force Offline")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Force Offline field';
                }
                field("Auto Reconcile On EOD"; "Auto Reconcile On EOD")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Reconcile On EOD field';
                }
                field("Force Abort Minimum Seconds"; "Force Abort Minimum Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Force Abort Minimum Seconds field';
                }
                field("Administration Timeout Seconds"; "Administration Timeout Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Administration Timeout Seconds field';
                }
                field("Lookup Timeout Seconds"; "Lookup Timeout Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lookup Timeout Seconds field';
                }
                field("Open Timeout Seconds"; "Open Timeout Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open Timeout Seconds field';
                }
                field("Close Timeout Seconds"; "Close Timeout Seconds")
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

