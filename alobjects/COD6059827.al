codeunit 6059827 "Upgrade NPR5.52"
{
    // [VLOBJUPG] Object may be deleted after upgrade
    // NPR5.52/ALPO/20190813 CASE 360258 Upgrade code to handle schema changes for table 6150669 "NPRE Restaurant Setup"
    // NPR5.52/ALPO/20190923 CASE 365326 Upgrade code to handle schema changes for table 6150613 "NP Retail Setup" (Posting related fields moved to POS Posting Profiles)
    // NPR5.52/SARA/20190924 CASE 368395 Delete field 'SMS Profile'(SMS profile move to POS End of Day Profile)
    // NPR5.52/MMV /20191004 CASE 352472 Renamed prepayment parameters.
    // NPR5.52/MHA /20191016 CASE 371388 "Global POS Sales Setup" moved from Np Retail Setup to POS Unit
    // NPR5.52/MHA /20191016 CASE 373294 Added function UpgPaymentTypePOS()
    // NPR5.52/CLVA/20191104 CASE 375749 Added code to UpgradeTables function

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    procedure UpgradeTables(var TableSynchSetup: Record "Table Synch. Setup")
    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        //-NPR5.52 [360258]
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"NPRE Restaurant Setup", DATABASE::"Upgrade NPRE Restaurant Setup", TableSynchSetup.Mode::Move);  //Field 'Auto print kintchen order' type changed from boolean to option
        //+NPR5.52 [360258]

        //-NPR5.52 [365326]
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"NP Retail Setup", DATABASE::"Upgrade NP Retail Setup", TableSynchSetup.Mode::Move);  //Posting related fields moved to POS Posting Profiles from NP Retail Setup
        //+NPR5.52 [365326]

        //-NPR5.52 [368395]
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"POS Unit", 0, TableSynchSetup.Mode::Force);  //SMS profile move to POS End of Day Profile
        //+NPR5.52 [368395]

        //-NPR5.52 [375749]
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"CS Posting Buffer", 0, TableSynchSetup.Mode::Force);
        //+NPR5.52 [375749]
    end;

    trigger OnUpgradePerCompany()
    begin
        MoveAndUpgradeTRestSetup;  //NPR5.52 [360258]
        MoveNPRetailSetup;  //NPR5.52 [365326]
        RenameParameters(); //NPR5.52 [352473]
        //-NPR5.52 [373294]
        UpgPaymentTypePOS();
        //+NPR5.52 [373294]
    end;

    procedure MoveAndUpgradeTRestSetup()
    var
        NPRERestaurantSetup: Record "NPRE Restaurant Setup";
        UpgradeNPRERestaurantSetup: Record "Upgrade NPRE Restaurant Setup";
    begin
        //-NPR5.52 [360258]
        with UpgradeNPRERestaurantSetup do
            if FindSet then
                repeat
                    NPRERestaurantSetup.Init;
                    NPRERestaurantSetup.Code := Code;
                    if not NPRERestaurantSetup.Find then
                        NPRERestaurantSetup.Insert;
                    NPRERestaurantSetup."Waiter Pad No. Serie" := "Waiter Pad No. Serie";
                    NPRERestaurantSetup."Kitchen Order Template" := "Kitchen Order Template";
                    NPRERestaurantSetup."Pre Receipt Template" := "Pre Receipt Template";
                    if "Auto Print Kitchen Order" then
                        NPRERestaurantSetup."Auto Print Kitchen Order" := NPRERestaurantSetup."Auto Print Kitchen Order"::Yes
                    else
                        NPRERestaurantSetup."Auto Print Kitchen Order" := NPRERestaurantSetup."Auto Print Kitchen Order"::No;
                    NPRERestaurantSetup.Modify;

                    Delete;
                until Next = 0;
        //+NPR5.52 [360258]
    end;

    procedure MoveNPRetailSetup()
    var
        NPRetailSetup: Record "NP Retail Setup";
        UpgradeNPRetailSetup: Record "Upgrade NP Retail Setup";
        POSPostingProfile: Record "POS Posting Profile";
        POSUnit: Record "POS Unit";
    begin
        //-NPR5.52 [365326]
        with UpgradeNPRetailSetup do
            if FindSet then
                repeat
                    POSPostingProfile.Init;
                    POSPostingProfile.Code := 'DEFAULT';
                    if not POSPostingProfile.Find then
                        POSPostingProfile.Insert;
                    POSPostingProfile.Description := 'Default POS Posting Profile';
                    POSPostingProfile."Default POS Entry No. Series" := "Default POS Entry No. Series";
                    POSPostingProfile."Max. POS Posting Diff. (LCY)" := "Max. POS Posting Diff. (LCY)";
                    POSPostingProfile."POS Posting Diff. Account" := "POS Posting Diff. Account";
                    POSPostingProfile."Automatic Item Posting" := "Automatic Item Posting";
                    POSPostingProfile."Automatic POS Posting" := "Automatic POS Posting";
                    POSPostingProfile."Automatic Posting Method" := "Automatic Posting Method";
                    POSPostingProfile."Adj. Cost after Item Posting" := "Adj. Cost after Item Posting";
                    POSPostingProfile."Post to G/L after Item Posting" := "Post to G/L after Item Posting";
                    POSPostingProfile.Modify;

                    if POSUnit.FindSet then
                        repeat
                            if POSUnit."POS Posting Profile" = '' then begin
                                POSUnit."POS Posting Profile" := POSPostingProfile.Code;
                                POSUnit.Modify;
                            end;
                        until POSUnit.Next = 0;

                    //-NPR5.52 [371388]
                    if "Global POS Sales Setup" <> '' then
                        POSUnit.ModifyAll("Global POS Sales Setup", "Global POS Sales Setup");
                    //+NPR5.52 [371388]

                    NPRetailSetup.Init;
                    NPRetailSetup."Primary Key" := UpgradeNPRetailSetup."Primary Key";
                    if not NPRetailSetup.Find then
                        NPRetailSetup.Insert;
                    NPRetailSetup.TransferFields(UpgradeNPRetailSetup, true);
                    NPRetailSetup."Default POS Posting Profile" := POSPostingProfile.Code;
                    NPRetailSetup.Modify;

                    Delete;
                until Next = 0;
        //+NPR5.52 [365326]
    end;

    procedure RenameParameters()
    var
        POSParameterValue: Record "POS Parameter Value";
        POSActionParameter: Record "POS Action Parameter";
    begin
        //-NPR5.52 [352473]
        RenamePOSParameterValue('SALES_DOC_EXPORT', 'PrepaymentPctDialog', 'PrepaymentDialog');
        RenamePOSActionParameter('SALES_DOC_EXPORT', 'PrepaymentPctDialog', 'PrepaymentDialog');
        RenamePOSParameterValue('SALES_DOC_EXPORT', 'FixedPrepaymentPct', 'FixedPrepaymentValue');
        RenamePOSActionParameter('SALES_DOC_EXPORT', 'FixedPrepaymentPct', 'FixedPrepaymentValue');
        RenamePOSParameterValue('SALES_DOC_EXPORT', 'PrintPayAndPostInvoice', 'PrintPayAndPostDocument');
        RenamePOSActionParameter('SALES_DOC_EXPORT', 'PrintPayAndPostInvoice', 'PrintPayAndPostDocument');

        RenamePOSParameterValue('SALES_DOC_PREPAY', 'PrepaymentPctDialog', 'Dialog');
        RenamePOSActionParameter('SALES_DOC_PREPAY', 'PrepaymentPctDialog', 'Dialog');
        RenamePOSParameterValue('SALES_DOC_PREPAY', 'FixedPrepaymentPct', 'FixedValue');
        RenamePOSActionParameter('SALES_DOC_PREPAY', 'FixedPrepaymentPct', 'FixedValue');
        RenamePOSParameterValue('SALES_DOC_PREPAY', 'AmountPayment', 'InputIsAmount');
        RenamePOSActionParameter('SALES_DOC_PREPAY', 'AmountPayment', 'InputIsAmount');
        RenamePOSParameterValue('SALES_DOC_PREPAY', 'PrintPrepaymentDocument', 'PrintDocument');
        RenamePOSActionParameter('SALES_DOC_PREPAY', 'PrintPrepaymentDocument', 'PrintDocument');

        RenamePOSParameterValue('SALES_DOC_PAY_POST', 'PrintInvoice', 'PrintDocument');
        RenamePOSActionParameter('SALES_DOC_PAY_POST', 'PrintInvoice', 'PrintDocument');
        //+NPR5.52 [352473]
    end;

    procedure RenamePOSParameterValue(ActionCode: Text; CurrentName: Text; NewName: Text)
    var
        POSParameterValue: Record "POS Parameter Value";
        POSParameterValue2: Record "POS Parameter Value";
    begin
        //-NPR5.52 [352473]
        with POSParameterValue do begin
            SetRange("Action Code", ActionCode);
            SetRange(Name, CurrentName);
            if not FindSet(true, true) then
                exit;

            repeat
                POSParameterValue2 := POSParameterValue;
                POSParameterValue2.Rename("Table No.", Code, ID, "Record ID", NewName);
            until Next = 0;
        end;
        //+NPR5.52 [352473]
    end;

    procedure RenamePOSActionParameter(ActionCode: Text; CurrentName: Text; NewName: Text)
    var
        POSActionParameter: Record "POS Action Parameter";
        POSActionParameter2: Record "POS Action Parameter";
    begin
        //-NPR5.52 [352473]
        with POSActionParameter do begin
            SetRange("POS Action Code", ActionCode);
            SetRange(Name, CurrentName);
            if not FindSet(true, true) then
                exit;

            repeat
                POSActionParameter2 := POSActionParameter;
                POSActionParameter2.Rename("POS Action Code", NewName);
            until Next = 0;
        end;
        //+NPR5.52 [352473]
    end;

    local procedure UpgPaymentTypePOS()
    var
        PaymentTypePOS: Record "Payment Type POS";
    begin
        //-NPR5.52 [373294]
        PaymentTypePOS.SetFilter("Fixed Rate", '=%1', 0);
        PaymentTypePOS.SetRange("Allow Cashback", false);
        if PaymentTypePOS.FindFirst then
            PaymentTypePOS.ModifyAll("Allow Cashback", true);
        //+NPR5.52 [373294]
    end;
}

