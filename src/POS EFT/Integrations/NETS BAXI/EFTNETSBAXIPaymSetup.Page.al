page 6184509 "NPR EFT NETS BAXI Paym. Setup"
{
    // NPR5.54/JAKUBV/20200408  CASE 364340 Transport NPR5.54 - 8 April 2020

    Caption = 'EFT NETS BAXI Payment Setup';
    PageType = Card;
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
                }
                field("Trace Level"; "Trace Level")
                {
                    ApplicationArea = All;
                }
                field("Baud Rate"; "Baud Rate")
                {
                    ApplicationArea = All;
                }
                field("COM Port"; "COM Port")
                {
                    ApplicationArea = All;
                }
                field("Host Environment"; "Host Environment")
                {
                    ApplicationArea = All;
                }
                field("Cutter Support"; "Cutter Support")
                {
                    ApplicationArea = All;
                }
                field("Printer Width"; "Printer Width")
                {
                    ApplicationArea = All;
                }
                field("Display Width"; "Display Width")
                {
                    ApplicationArea = All;
                }
                field("Log Auto Delete Days"; "Log Auto Delete Days")
                {
                    ApplicationArea = All;
                }
                field("Socket Listener"; "Socket Listener")
                {
                    ApplicationArea = All;
                }
                field("Socket Listener Port"; "Socket Listener Port")
                {
                    ApplicationArea = All;
                }
                field("Bluetooth Tunnel"; "Bluetooth Tunnel")
                {
                    ApplicationArea = All;
                }
                field("Link Control Timeout Seconds"; "Link Control Timeout Seconds")
                {
                    ApplicationArea = All;
                }
                field(DCC; DCC)
                {
                    ApplicationArea = All;
                }
                field("Force Offline"; "Force Offline")
                {
                    ApplicationArea = All;
                }
                field("Auto Reconcile On EOD"; "Auto Reconcile On EOD")
                {
                    ApplicationArea = All;
                }
                field("Force Abort Minimum Seconds"; "Force Abort Minimum Seconds")
                {
                    ApplicationArea = All;
                }
                field("Administration Timeout Seconds"; "Administration Timeout Seconds")
                {
                    ApplicationArea = All;
                }
                field("Lookup Timeout Seconds"; "Lookup Timeout Seconds")
                {
                    ApplicationArea = All;
                }
                field("Open Timeout Seconds"; "Open Timeout Seconds")
                {
                    ApplicationArea = All;
                }
                field("Close Timeout Seconds"; "Close Timeout Seconds")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

