﻿page 6151012 "NPR NpRv Voucher Type Card"
{
    Extensible = true;
    UsageCategory = None;
    Caption = 'Retail Voucher Type Card';
    ContextSensitiveHelpPage = 'docs/retail/vouchers/explanation/voucher_types/';
    PromotedActionCategories = 'New,Process,Reports,Manage,Setup';
    SourceTable = "NPR NpRv Voucher Type";
#if NOT BC17
    AboutTitle = 'Voucher Type';
    AboutText = 'This page is used to configure and manage Voucher Types. Voucher types enable you to create, send, set up, and validate vouchers for various purposes. Personalize voucher types to suit your business requirements and efficiently distribute value to recipients';
#endif

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
#if NOT BC17
                AboutTitle = 'General Information';
                AboutText = 'This section is used to access general information about the Voucher Type. Here, you can find details such as the voucher type''s name, description, and any relevant information that distinguishes it from other voucher types.';
#endif
                group(Control6014420)
                {
                    ShowCaption = false;
                    field("Code"; Rec.Code)
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Description; Rec.Description)
                    {

                        ToolTip = 'Specifies the value of the Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Voucher Category"; Rec."Voucher Category")
                    {
                        ToolTip = 'Specifies the category of vouchers of this type. Voucher categories are used for reporting purposes.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014424)
                {
                    ShowCaption = false;
                    field("Voucher Qty. (Open)"; VoucherQtyOpen)
                    {
                        Caption = 'Voucher Qty. (Open)';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Voucher Qty. (Open) field';
                        ApplicationArea = NPRRetail;

                        trigger OnDrillDown()
                        var
                        begin
                            Rec.DrilldownCalculatedFields(Rec.FieldNo("Voucher Qty. (Open)"));
                        end;
                    }
                    field("Voucher Qty. (Closed)"; VoucherQtyClosed)
                    {
                        Caption = 'Voucher Qty. (Closed)';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Voucher Qty. (Closed) field';
                        ApplicationArea = NPRRetail;
                        trigger OnDrillDown()
                        var
                        begin
                            Rec.DrilldownCalculatedFields(Rec.FieldNo("Voucher Qty. (Closed)"));
                        end;
                    }
                    field("Arch. Voucher Qty."; VoucherQtyArchived)
                    {
                        Caption = 'Archived Voucher Qty.';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Archived Voucher Qty. field';
                        ApplicationArea = NPRRetail;
                        trigger OnDrillDown()
                        var
                        begin
                            Rec.DrilldownCalculatedFields(Rec.FieldNo("Arch. Voucher Qty."));
                        end;
                    }
                }
            }
            group("Send Voucher")
            {
                Caption = 'Send Voucher';
#if NOT BC17
                AboutTitle = 'Send Voucher';
                AboutText = 'This section is used to initiate the process of sending vouchers to recipients. You can specify the recipients, voucher details, and distribution method to ensure vouchers are delivered accurately to intended recipients.';
#endif
                group(Control6014425)
                {
                    ShowCaption = false;
                    field("Send Voucher Module"; Rec."Send Voucher Module")
                    {

                        ToolTip = 'Specifies the value of the Send Voucher Module field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Account No."; Rec."Account No.")
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Account No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Partner Code"; Rec."Partner Code")
                    {

                        ToolTip = 'Specifies the value of the Partner Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Allow Top-up"; Rec."Allow Top-up")
                    {

                        ToolTip = 'Specifies the value of the Allow Top-up field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Minimum Amount Issue"; Rec."Minimum Amount Issue")
                    {

                        ToolTip = 'Specifies the value of the Minimum Amount Issue field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Max Voucher Count"; Rec."Max Voucher Count")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Max Voucher Count field. If value in this field is 0, there will be no checks.';
                    }
                }
                group(Control6014426)
                {
                    ShowCaption = false;
                    field("No. Series"; Rec."No. Series")
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the No. Series field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Arch. No. Series"; Rec."Arch. No. Series")
                    {

                        ToolTip = 'Specifies the value of the Archivation No. Series field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Reference No. Type"; Rec."Reference No. Type")
                    {

                        ToolTip = 'Specifies the value of the Reference No. Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Manual Reference number SO"; Rec."Manual Reference number SO")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies if vouchers created at sales order will have manually entered reference number.';
                    }
                    field("Top-up Extends Ending Date"; Rec."Top-up Extends Ending Date")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies if Top-up or Partner Top-up extends Ending Date using.';
                    }

                    group(Control6014407)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Reference No. Type" = 0);
                        field("Reference No. Pattern"; Rec."Reference No. Pattern")
                        {


                            ToolTip = '[S] ~ Voucher No. || [N] ~ Random Number || [N*3] ~ 3 Random Numbers || [AN] ~ Random Char || [AN*3] ~ 3 Random Chars. In case of EAN13, the Reference No. Pattern should be 12 characters. The 13th character ishe check-digit generated by the system.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Control6014405)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Reference No. Type" = 1);
                        field(EAN13ReferenceNoPattern; Rec."Reference No. Pattern")
                        {

                            ToolTip = '[S] ~ Voucher No. || [N] ~ Random Number || [N*3] ~ 3 Random Numbers. In case of EAN13, the Reference No. Pattern should be 12 characters. The 13th character ishe check-digit generated by the system.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
                group(OutputMethod)
                {
                    ShowCaption = false;
                    field("Print Object Type"; Rec."Print Object Type")
                    {
                        ToolTip = 'Specifies the print object type for the voucher type';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            UpdateControls();
                        end;
                    }
                    field("Print Object ID"; Rec."Print Object ID")
                    {
                        Enabled = not PrintUsingTemplate;
                        ToolTip = 'Specifies the print object Id for the voucher type';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Template Code"; Rec."Print Template Code")
                    {
                        Enabled = PrintUsingTemplate;
                        ToolTip = 'Specifies the value of the Print Template Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("E-mail Template Code"; Rec."E-mail Template Code")
                    {

                        ToolTip = 'Specifies the value of the E-mail Template Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("SMS Template Code"; Rec."SMS Template Code")
                    {

                        ToolTip = 'Specifies the value of the SMS Template Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Send Method via POS"; Rec."Send Method via POS")
                    {

                        ToolTip = 'Specifies the value of the Send Method via POS field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Voucher Message"; Rec."Voucher Message")
                    {

                        MultiLine = true;
                        ToolTip = 'Specifies the value of the Voucher Message field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Setup Voucher")
            {
                Caption = 'Setup Voucher';
#if NOT BC17
                AboutTitle = 'Setup Voucher';
                AboutText = 'This section is used to configure the settings and parameters of the voucher type. You can define rules, expiration dates, and any restrictions associated with the vouchers, ensuring they align with your business''s needs and promotions.';
#endif

                field("Voucher Amount"; Rec."Voucher Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Voucher Amount field. If this field is specified all vouchers will be issued with this amount.';
                }
                field("POS Store Group"; Rec."POS Store Group")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Store Group field. If this field is populated, vouchers can be used only in stores that are assigned to selected POS Store Group.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Starting Date field. If this field is specified all vouchers will be issued with this Starting Date.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Ending Date field. If this field is specified all vouchers will be issued with this Ending Date.';
                }
            }
            group("Validate Voucher")
            {
                Caption = 'Validate Voucher';
#if NOT BC17
                AboutTitle = 'Validate Voucher';
                AboutText = 'Use this section to validate vouchers presented by customers or recipients. Verify that the voucher conditions are met and that it is still valid for use. Ensure seamless redemption experience for customers by confirming voucher eligibility.';
#endif
                group(Control6014427)
                {
                    ShowCaption = false;
                    field("Validate Voucher Module"; Rec."Validate Voucher Module")
                    {

                        ToolTip = 'Specifies the value of the Validate Voucher Module field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014428)
                {
                    ShowCaption = false;
                    field("Validate Customer No."; Rec."Validate Customer No.")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Validate Customer No. field. If this field is selected and voucher was issued to a customer this voucher can be spend only by that customer.';
                    }
                    field("Valid Period"; Rec."Valid Period")
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Valid Period field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Apply Payment")
            {
                Caption = 'Apply Payment';
#if NOT BC17
                AboutTitle = 'Apply Payment';
                AboutText = 'Navigate to this section to confirm payments made using vouchers. Ensure that payments are valid and in compliance with voucher terms and conditions. Verify that the voucher''s value has been correctly applied to the transaction, providing a seamless and accurate payment experience for customers.';
#endif
                field("Apply Payment Module"; Rec."Apply Payment Module")
                {
                    ToolTip = 'Specifies the value of the Apply Payment Module field';
#if not BC17
                    Editable = not Rec."Integrate with Shopify";
#endif
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        if Rec."Apply Payment Module" <> xRec."Apply Payment Module" then
                            CurrPage.Update();
                    end;
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Payment Type field';
                    ApplicationArea = NPRRetail;
                }
            }
#if not BC17
            group(Shopify)
            {
                Caption = 'Shopify';
                Visible = ShopifyIntegrationIsEnabled;
                field("Integrate with Shopify"; Rec."Integrate with Shopify")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies if retail vouchers of this type are integrated with Shopify.';
                }
                field("Spfy Auto-Fulfill"; Rec."Spfy Auto-Fulfill")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies if retail vouchers of this type sold on Shopify must be automatically fulfilled (posted as shipped in BC) immediately after the Shopify order is imported into BC. Please note that this will not work for Shopify gift cards with reference numbers assigned by Shopify, as these must be fulfilled in Shopify.';
                }
                field(ShopifyStoreCode; ShopifyStoreCode)
                {
                    Caption = 'Shopify Store Code';
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the Shopify store retail vouchers of this type are integrated with.';
                    TableRelation = "NPR Spfy Store";

                    trigger OnValidate()
                    var
                        ShopifyStore: Record "NPR Spfy Store";
                        xShopifyStoreCode: Code[20];
                    begin
                        Rec.TestField(Code);
                        CurrPage.SaveRecord();

                        xShopifyStoreCode := Rec.GetStoreCode();
                        if ShopifyStoreCode = xShopifyStoreCode then
                            exit;
                        Rec.TestField("Integrate with Shopify", false);
                        if ShopifyStoreCode <> '' then begin
                            ShopifyStore.Code := ShopifyStoreCode;
                            ShopifyStore.Find('=><');
                            ShopifyStoreCode := ShopifyStore.Code;
                        end;
                        Rec.CheckVoucherTypeIsNotInUse(ShopifyStoreCode);
                        SpfyAssignedIDMgt.AssignShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Store Code", ShopifyStoreCode, false);
                    end;
                }
            }
#endif
        }
    }

    actions
    {
        area(navigation)
        {
            group(Setup)
            {
                action("Setup Send Voucher")
                {
                    Caption = 'Setup Send Voucher';
                    Image = VoucherGroup;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasIssueVoucherSetup;

                    ToolTip = 'Executes the Setup Send Voucher action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
                    begin
                        NpRvModuleMgt.OnSetupSendVoucher(Rec);
                    end;
                }
                action("Setup Validate Voucher")
                {
                    Caption = 'Setup Validate Voucher';
                    Image = RefreshVoucher;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasValidateVoucherSetup;

                    ToolTip = 'Executes the Setup Validate Voucher action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
                    begin
                        NpRvModuleMgt.OnSetupValidateVoucher(Rec);
                    end;
                }
                action("Setup Apply Payment")
                {
                    Caption = 'Setup Apply Payment';
                    Image = Voucher;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasApplyPaymentSetup;

                    ToolTip = 'Executes the Setup Apply Payment action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
                    begin
                        NpRvModuleMgt.OnSetupApplyPayment(Rec);
                    end;
                }
            }
            separator(Separator6014431)
            {
            }
            action(Vouchers)
            {
                Caption = 'Vouchers';
                Image = Voucher;
                RunObject = Page "NPR NpRv Vouchers";
                RunPageLink = "Voucher Type" = FIELD(Code);
                ShortCutKey = 'Ctrl+F7';

                ToolTip = 'Executes the Vouchers action';
                ApplicationArea = NPRRetail;
            }
            action("Partner Card")
            {
                Caption = 'Partner Card';
                Image = UserSetup;
                RunObject = Page "NPR NpRv Partner Card";
                RunPageLink = Code = FIELD("Partner Code");
                Visible = Rec."Partner Code" <> '';

                ToolTip = 'Executes the Partner Card action';
                ApplicationArea = NPRRetail;
            }
            action("Partner Relations")
            {
                Caption = 'Partner Relations';
                Image = UserCertificate;
                RunObject = Page "NPR NpRv Partner Relations";
                RunPageLink = "Voucher Type" = FIELD(Code);

                ToolTip = 'Executes the Partner Relations action';
                ApplicationArea = NPRRetail;
            }
        }
    }

#if not BC17
    trigger OnOpenPage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        ShopifyIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Retail Vouchers");
    end;
#endif

    trigger OnAfterGetCurrRecord()
    begin
        SetHasSetup();
        UpdateControls();

        VoucherQtyOpen := LoadingTxt;
        VoucherQtyClosed := LoadingTxt;
        VoucherQtyArchived := LoadingTxt;
        EnqueueFlowFieldsCalculationBackgroundTask();

#if not BC17
        if ShopifyIntegrationIsEnabled then
            ShopifyStoreCode := Rec.GetStoreCode();
#endif
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    begin
        VoucherQtyOpen := GetFieldValueFromBackgroundTaskResultSet(Results, Format(Rec.FieldNo("Voucher Qty. (Open)")));
        VoucherQtyClosed := GetFieldValueFromBackgroundTaskResultSet(Results, Format(Rec.FieldNo("Voucher Qty. (Closed)")));
        VoucherQtyArchived := GetFieldValueFromBackgroundTaskResultSet(Results, Format(Rec.FieldNo("Arch. Voucher Qty.")));
    end;

    var
        HasApplyPaymentSetup: Boolean;
        HasIssueVoucherSetup: Boolean;
        HasValidateVoucherSetup: Boolean;
        PrintUsingTemplate: Boolean;
        VoucherQtyOpen, VoucherQtyClosed, VoucherQtyArchived : Text;
        BackgroundTaskId: Integer;
        LoadingTxt: Label 'Loading...', Locked = true;
#if not BC17
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShopifyStoreCode: Code[20];
        ShopifyIntegrationIsEnabled: Boolean;
#endif

    local procedure SetHasSetup()
    var
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
    begin
        HasIssueVoucherSetup := false;
        NpRvModuleMgt.OnHasSendVoucherSetup(Rec, HasIssueVoucherSetup);

        HasValidateVoucherSetup := false;
        NpRvModuleMgt.OnHasValidateVoucherSetup(Rec, HasValidateVoucherSetup);

        HasApplyPaymentSetup := false;
        NpRvModuleMgt.OnHasApplyPaymentSetup(Rec, HasApplyPaymentSetup);

        CurrPage.Update(false);
    end;

    local procedure UpdateControls()
    begin
        PrintUsingTemplate := Rec."Print Object Type" = Rec."Print Object Type"::Template;
    end;

    local procedure EnqueueFlowFieldsCalculationBackgroundTask()
    var
        BackgroundTaskParameters: Dictionary of [Text, Text];
    begin
        if (BackgroundTaskId <> 0) then
            CurrPage.CancelBackgroundTask(BackgroundTaskId);
        BackgroundTaskParameters.Add('VoucherTypeCode', Rec.Code);
        BackgroundTaskParameters.Add(Format(Rec.FieldNo("Voucher Qty. (Open)")), '');
        BackgroundTaskParameters.Add(Format(Rec.FieldNo("Voucher Qty. (Closed)")), '');
        BackgroundTaskParameters.Add(Format(Rec.FieldNo("Arch. Voucher Qty.")), '');
        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"NPR NpRv Ret. Vouch. Type Task", BackgroundTaskParameters);
    end;

    local procedure GetFieldValueFromBackgroundTaskResultSet(var BackgroundTaskResults: Dictionary of [Text, Text]; FieldNo: Text) Result: Text
    begin
        if not BackgroundTaskResults.ContainsKey(FieldNo) then
            exit('0');
        Result := BackgroundTaskResults.Get(FieldNo);
        if Result = '' then
            Result := '0';
    end;
}
