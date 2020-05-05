codeunit 6059827 "Upgrade NPR5.54"
{
    // [VLOBJUPG] Object may be deleted after upgrade
    // NPR5.54/ALPO/20200110 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale
    // NPR5.54/ALPO/20200218 CASE 388951 Removed step SuggestItemAddOnsOnSaleLineInsert from Sale Workflow AFTER_INSERT_LINE
    // NPR5.54/ALPO/20200227 CASE 355871 New field Raptor tracking service type
    // NPR5.54/TJ  /20200302 CASE 393478 Removing unused fields from "Retail Setup"
    // NPR5.54/TJ  /20200303 CASE 393290 Removing unused fields from "MPOS App Setup"
    // NPR5.54/BHR /20200309 CASE 389444 copy setup from "Cash register"/"retail setup" text profiles to 'POS Unit Receipt Text Profile'
    // NPR5.54/ALPO/20200310 CASE 394528 Update legacy global dim fields on cash registers from POS units

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [TableSyncSetup]
    procedure UpgradeTables(var TableSynchSetup: Record "Table Synch. Setup")
    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        //DataUpgradeMgt.SetTableSyncSetup(<Table ID>,<Upgrade Table ID>,TableSynchSetup.Mode::<Synch Mode>);
        //-NPR5.54 [393478]
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Retail Setup",0,TableSynchSetup.Mode::Force);
        //+NPR5.54 [393478]
        //-NPR5.54 [393290]
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"MPOS App Setup",0,TableSynchSetup.Mode::Force);
        //+NPR5.54 [393290]
    end;

    [UpgradePerCompany]
    procedure InitRestaurantSetup()
    var
        RestSetup: Record "NPRE Restaurant Setup";
    begin
        //-NPR5.54 [382428]
        if not RestSetup.ReadPermission then
          exit;
        if RestSetup.Get() then begin
          RestSetup."Kitchen Printing Active" := true;
          RestSetup.Modify;
        end;
        //+NPR5.54 [382428]
    end;

    [UpgradePerCompany]
    procedure ArchiveUnfinishedSaleTransactions()
    var
        ArchiveSalePOS: Record "Archive Sale POS";
        ArchiveSaleLinePOS: Record "Archive Sale Line POS";
        NpDcSaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
        NpDcSaleLinePOSNewCoupon: Record "NpDc Sale Line POS New Coupon";
        NpIaSaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
        NpRvSaleLinePOSReference: Record "NpRv Sale Line POS Reference";
        NpRvSaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
        POSInfoTransaction: Record "POS Info Transaction";
        RetailCrossReference: Record "Retail Cross Reference";
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        POSQuoteMgt: Codeunit "POS Quote Mgt.";
        XmlDoc: DotNet npNetXmlDocument;
        OutStr: OutStream;
    begin
        //-NPR5.54 [364658]
        if SalePOS.FindSet then
          repeat
            ArchiveSalePOS.TransferFields(SalePOS,true);
            if ArchiveSalePOS.Insert then;

            POSQuoteMgt.POSSale2Xml(SalePOS,XmlDoc);
            ArchiveSalePOS."POS Sales Data".CreateOutStream(OutStr,TEXTENCODING::UTF8);
            XmlDoc.Save(OutStr);
            ArchiveSalePOS.Modify;
          until SalePOS.Next = 0;

        if SaleLinePOS.FindSet then
          repeat
            ArchiveSaleLinePOS.TransferFields(SaleLinePOS,true);
            if ArchiveSaleLinePOS.Insert then;
          until SaleLinePOS.Next = 0;

        POSInfoTransaction.DeleteAll;
        NpIaSaleLinePOSAddOn.DeleteAll;
        NpRvSaleLinePOSVoucher.DeleteAll;
        NpRvSaleLinePOSReference.DeleteAll;
        NpDcSaleLinePOSCoupon.DeleteAll;
        NpDcSaleLinePOSNewCoupon.DeleteAll;

        RetailCrossReference.SetFilter("Table ID",'%1|%2',DATABASE::"Sale POS",DATABASE::"Sale Line POS");
        RetailCrossReference.DeleteAll;

        SaleLinePOS.DeleteAll;
        SalePOS.DeleteAll;
        //+NPR5.54 [364658]
    end;

    [UpgradePerCompany]
    procedure RemoveItemAddOnWFStep()
    var
        POSSalesWorkflowStep: Record "POS Sales Workflow Step";
    begin
        //-NPR5.54 [388951]
        POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID",CODEUNIT::"POS Action - Run Item AddOn");
        POSSalesWorkflowStep.SetRange("Subscriber Function",'SuggestItemAddOnsOnSaleLineInsert');
        POSSalesWorkflowStep.DeleteAll;
        //+NPR5.54 [388951]
    end;

    [UpgradePerCompany]
    procedure UpdateRaptorSetup()
    var
        RaptorSetup: Record "Raptor Setup";
        RaptorMgt: Codeunit "Raptor Management";
    begin
        //-NPR5.54 [355871]
        if not RaptorSetup.Get then
          exit;
        if RaptorSetup."Tracking Service Type" = '' then begin
          RaptorMgt.GetDefaultTrackingServiceType(RaptorSetup."Tracking Service Type");
          RaptorSetup.Modify;
        end;
        //+NPR5.54 [355871]
    end;

    [UpgradePerCompany]
    procedure CopyTextProfile()
    var
        RetailSetup: Record "Retail Setup";
        Register: Record Register;
        POSUnitReceiptTextProfile: Record "POS Unit Receipt Text Profile";
        NPRetailSetup: Record "NP Retail Setup";
        POSUnit: Record "POS Unit";
        RetailComment: Record "Retail Comment";
        RetailComment_register: Record "Retail Comment";
    begin
        //-NPR5.54 [389444]
        if not RetailSetup.Get then
          exit;

        if not NPRetailSetup.Get then
          exit;

        if not  NPRetailSetup."Advanced POS Entries Activated" then
          exit;

        POSUnitReceiptTextProfile.Init;
        POSUnitReceiptTextProfile.Code := 'NP CONFIG';
        POSUnitReceiptTextProfile."Sales Ticket Line Text off" := POSUnitReceiptTextProfile."Sales Ticket Line Text off"::"Pos Unit";
        POSUnitReceiptTextProfile."Sales Ticket Line Text1" := RetailSetup."Sales Ticket Line Text1";
        POSUnitReceiptTextProfile."Sales Ticket Line Text2" := RetailSetup."Sales Ticket Line Text2";
        POSUnitReceiptTextProfile."Sales Ticket Line Text3" := RetailSetup."Sales Ticket Line Text3";
        POSUnitReceiptTextProfile."Sales Ticket Line Text4" := RetailSetup."Sales Ticket Line Text4";
        POSUnitReceiptTextProfile."Sales Ticket Line Text5" := RetailSetup."Sales Ticket Line Text5";
        POSUnitReceiptTextProfile."Sales Ticket Line Text6" := RetailSetup."Sales Ticket Line Text6";
        POSUnitReceiptTextProfile."Sales Ticket Line Text7" := RetailSetup."Sales Ticket Line Text7";
        if POSUnitReceiptTextProfile.Insert then;

        if Register.FindSet then
           repeat
             if POSUnit.Get(Register."Register No.") then begin
               if Register."Sales Ticket Line Text off" = Register."Sales Ticket Line Text off"::"NP Config" then
                begin
                 POSUnit."POS Unit Receipt Text Profile" := 'NP CONFIG';
                 POSUnit.Modify;
                end;

               if Register."Sales Ticket Line Text off" = Register."Sales Ticket Line Text off"::Register then
                 begin
                  POSUnitReceiptTextProfile.Init;
                  POSUnitReceiptTextProfile.Code := Register."Register No.";
                  POSUnitReceiptTextProfile."Sales Ticket Line Text off" := POSUnitReceiptTextProfile."Sales Ticket Line Text off"::"Pos Unit";
                  POSUnitReceiptTextProfile."Sales Ticket Line Text1" := Register."Sales Ticket Line Text1";
                  POSUnitReceiptTextProfile."Sales Ticket Line Text2" := Register."Sales Ticket Line Text2";
                  POSUnitReceiptTextProfile."Sales Ticket Line Text3" := Register."Sales Ticket Line Text3";
                  POSUnitReceiptTextProfile."Sales Ticket Line Text4" := Register."Sales Ticket Line Text4";
                  POSUnitReceiptTextProfile."Sales Ticket Line Text5" := Register."Sales Ticket Line Text5";
                  POSUnitReceiptTextProfile."Sales Ticket Line Text6" := Register."Sales Ticket Line Text6";
                  POSUnitReceiptTextProfile."Sales Ticket Line Text7" := Register."Sales Ticket Line Text7";
                  POSUnitReceiptTextProfile."Sales Ticket Line Text8" := Register."Sales Ticket Line Text8";
                  POSUnitReceiptTextProfile."Sales Ticket Line Text9" := Register."Sales Ticket Line Text9";
                  if POSUnitReceiptTextProfile.Insert then;

                  POSUnit."POS Unit Receipt Text Profile" := Register."Register No.";
                  POSUnit.Modify;
                 end;

               if Register."Sales Ticket Line Text off" = Register."Sales Ticket Line Text off"::Comment then begin
                  POSUnitReceiptTextProfile.Init;
                  POSUnitReceiptTextProfile.Code := Register."Register No.";
                  POSUnitReceiptTextProfile."Sales Ticket Line Text off" := POSUnitReceiptTextProfile."Sales Ticket Line Text off"::Comment;
                  if POSUnitReceiptTextProfile.Insert then;

                  RetailComment_register.Reset;
                  RetailComment_register.SetRange("No.",Register."Register No.");
                  RetailComment_register.SetRange("Table ID",6014401);
                  RetailComment_register.SetRange(Integer,300);
                  if RetailComment_register.FindSet then
                    repeat
                      RetailComment.TransferFields(RetailComment_register);
                      RetailComment."Table ID" := 6150615;
                      RetailComment.Integer := 1000;
                      if RetailComment.Insert then;
                    until RetailComment_register.Next = 0;

                end;
             end;

        until Register.Next = 0;
        //+NPR5.54 [389444]
    end;

    [UpgradePerCompany]
    procedure UpdateCashRegGlobDims()
    var
        POSUnit: Record "POS Unit";
        CashRegister: Record Register;
    begin
        //-NPR5.54 [394528]
        /// Cash register supports only global dims (for legacy compatibility reasons).
        /// Those must be the same as the ones specified on the related POS Unit
        if POSUnit.FindSet then
          repeat
            if CashRegister.Get(POSUnit."No.") then
              if (CashRegister."Global Dimension 1 Code" <> POSUnit."Global Dimension 1 Code") or
                 (CashRegister."Global Dimension 2 Code" <> POSUnit."Global Dimension 2 Code")
              then begin
                CashRegister."Global Dimension 1 Code" := POSUnit."Global Dimension 1 Code";
                CashRegister."Global Dimension 2 Code" := POSUnit."Global Dimension 2 Code";
                CashRegister.Modify;
              end;
          until POSUnit.Next = 0;
        //+NPR5.54 [394528]
    end;
}

