page 6151500 "NPR Nc Setup"
{
    // NC1.01/MH/20150201  CASE 199932 Object created
    // NC1.03/TS/20150202  CASE 201682 Added fields related to Gift Voucher
    // NC1.04/MH/20150206  CASE 199932 Added field 20020 Variant System
    // NC1.05/MH/20150223  CASE 206395 Added B2B Modules Group and SetVisible function
    // NC1.06/TS/20150223  CASE 201682 Added Group Credit Voucher
    // NC1.07/TS/20150309  CASE 201682 Removed and Gift Voucher No.Series Management
    // NC1.09/MH/20150313  CASE 208758 Added function SetEnabled and NpXml Setup fields
    // NC1.10/TS/20150317  CASE 208237 Added Field Customer Template Code
    // NC1.11/MH/20150325  CASE 209616 Added Action for isolated setup of Task Queue and NpXml and field 10020 NpXml Task Worker Enabled
    // NC1.12/TS/20150407  CASE 210753 Added Credit Voucher Language Code
    // NC1.13/MH/20150409  CASE 211043 Added field 140 Salesperson Code
    // NC1.14/MH/20150415  CASE 211360 Added function InitFullSync actions
    // NC1.16/TS/20150423  CASE 212103 Added Import Codeunit fields
    // NC1.17/MH/20150619  CASE 216851 Magento and NpXml related fields moved to new setup tables
    // NC1.20/TS/20150804 CASE 219614 Added field Naviconnect Version
    // NC1.21/TS/20151014  CASE 225075 Added field 310 Max Task Count per Batch
    // NC1.21/TTH/20151118 CASE 227358 Removed Contact Import codeunit control.
    //                                 Removed Sales Order Transfer Fields
    // NC1.22/MHA/20160427 CASE 240212 Setup NaviConnect Action is split up into individual Actions: SetupWebservices(), SetupImportTypes(), SetupClienAddIns() and SetupTaskQueue()
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NaviConnect Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR Nc Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            field("Keep Tasks for"; "Keep Tasks for")
            {
                ApplicationArea = All;
            }
            group(General)
            {
                Caption = 'Order Import';
                field("Max Task Count per Batch"; "Max Task Count per Batch")
                {
                    ApplicationArea = All;
                }
            }
            group("Task Queue")
            {
                Caption = 'Task Queue';
                field("Task Queue Enabled"; "Task Queue Enabled")
                {
                    ApplicationArea = All;
                }
                field("Task Worker Group"; "Task Worker Group")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Setup Task Queue")
            {
                Caption = 'Setup Task Queue';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                var
                    NaviConnectMgt: Codeunit "NPR Nc Setup Mgt.";
                begin
                    CurrPage.Update(true);
                    //-NC1.17
                    //MagentoMgt.SetupTaskQueue();
                    NaviConnectMgt.SetupTaskQueue();
                    //+NC1.17
                end;
            }
        }
    }

    trigger OnClosePage()
    begin
        //-NC1.05
        //GiftVoucherVisible := FALSE ;
        //+NC1.05
    end;

    trigger OnOpenPage()
    var
        NaviConnectMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        Reset;
        //-NC1.17
        //IF NOT GET THEN BEGIN
        //  MagentoMgt.InitNaviConnectSetup();
        //END;
        if not Get then
            NaviConnectMgt.InitNaviConnectSetup();
        //+NC1.17
    end;
}

