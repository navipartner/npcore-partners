table 6151012 "NPR NpRv Voucher Type"
{
    Caption = 'Retail Voucher Type';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRv Voucher Types";
    LookupPageID = "NPR NpRv Voucher Types";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(15; "Arch. No. Series"; Code[20])
        {
            Caption = 'Archivation No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(20; "Reference No. Type"; Option)
        {
            Caption = 'Reference No. Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Pattern,EAN13';
            OptionMembers = Pattern,EAN13;
        }
        field(25; "Reference No. Pattern"; Code[20])
        {
            Caption = 'Reference No. Pattern';
            DataClassification = CustomerContent;
        }
        field(40; "Valid Period"; DateFormula)
        {
            Caption = 'Valid Period';
            DataClassification = CustomerContent;
        }
        field(45; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(55; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 "Direct Posting" = CONST(true));
        }
        field(60; "Partner Code"; Code[20])
        {
            Caption = 'Partner Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Partner";
        }
        field(62; "Allow Top-up"; Boolean)
        {
            Caption = 'Allow Top-up';
            DataClassification = CustomerContent;
        }
        field(63; "Print Object Type"; Enum "NPR Print Object Type")
        {
            Caption = 'Print Object Type';
            DataClassification = CustomerContent;
            InitValue = Template;
        }
        field(64; "Print Object ID"; Integer)
        {
            Caption = 'Print Object ID';
            DataClassification = CustomerContent;
            TableRelation = IF ("Print Object Type" = CONST(Codeunit)) AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Codeunit)) ELSE
            IF ("Print Object Type" = CONST(Report)) AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
            BlankZero = true;
        }
        field(65; "Print Template Code"; Code[20])
        {
            Caption = 'Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151013));
        }
        field(70; "Payment Type"; Code[10])
        {
            Caption = 'Payment Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(72; "Minimum Amount Issue"; Decimal)
        {
            Caption = 'Minimum Amount Issue';
            DataClassification = CustomerContent;
        }
        field(75; "E-mail Template Code"; Code[20])
        {
            Caption = 'E-mail Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header" WHERE("Table No." = CONST(6151013));
        }
        field(80; "SMS Template Code"; Code[10])
        {
            Caption = 'SMS Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header" WHERE("Table No." = CONST(6151013));
        }
        field(100; "Send Voucher Module"; Code[20])
        {
            Caption = 'Send Voucher Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Voucher Module".Code WHERE(Type = CONST("Send Voucher"));
        }
        field(105; "Send Method via POS"; Option)
        {
            Caption = 'Send Method via POS';
            DataClassification = CustomerContent;
            OptionCaption = 'Print,E-mail,SMS,Ask';
            OptionMembers = Print,"E-mail",SMS,Ask;
        }
        field(110; "Validate Voucher Module"; Code[20])
        {
            Caption = 'Validate Voucher Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Voucher Module".Code WHERE(Type = CONST("Validate Voucher"));
        }
        field(120; "Apply Payment Module"; Code[20])
        {
            Caption = 'Apply Payment Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Voucher Module".Code WHERE(Type = CONST("Apply Payment"));

#if not BC17
            trigger OnValidate()
            var
                ReturnVoucherType: Record "NPR NpRv Ret. Vouch. Type";
                PaymentModuleShopify: Codeunit "NPR NpRv Module Pay. - Shopify";
            begin
                if "Integrate with Shopify" then
                    TestField("Apply Payment Module", PaymentModuleShopify.ModuleCode());
                if "Apply Payment Module" = PaymentModuleShopify.ModuleCode() then begin
                    TestField(Code);
                    if not ReturnVoucherType.Get(Code) then begin
                        ReturnVoucherType.Init();
                        ReturnVoucherType."Voucher Type" := Code;
                        ReturnVoucherType.Insert();
                    end;
                    ReturnVoucherType."Return Voucher Type" := Code;
                    ReturnVoucherType.Modify();
                end;
            end;
#endif
        }
        field(200; "Max Voucher Count"; Integer)
        {
            Caption = 'Max Voucher Count';
            DataClassification = CustomerContent;
        }
        field(210; "Voucher Amount"; Decimal)
        {
            Caption = 'Voucher Amount';
            DataClassification = CustomerContent;
        }
        field(220; "POS Store Group"; Code[20])
        {
            Caption = 'POS Store Group';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store Group"."No.";
        }
        field(230; "Starting Date"; DateTime)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(235; "Ending Date"; DateTime)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
#if not BC17
        field(240; "Integrate with Shopify"; Boolean)
        {
            Caption = 'Integrate with Shopify';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PaymentModuleShopify: Codeunit "NPR NpRv Module Pay. - Shopify";
                SpfyRetailVoucherMgt: Codeunit "NPR Spfy Retail Voucher Mgt.";
            begin
                if "Integrate with Shopify" then begin
                    SpfyRetailVoucherMgt.CheckShopifyVoucherTypeReferenceNos(Rec.Code);
                    CheckStoreIsAssigned();
                    PaymentModuleShopify.CreateShopifyRetailVoucherModule();
                    Validate("Apply Payment Module", PaymentModuleShopify.ModuleCode());
                    Validate("Allow Top-up");
                end;
            end;
        }
        field(250; "Spfy Auto-Fulfill"; Boolean)
        {
            Caption = 'Auto-Fulfill';
            DataClassification = CustomerContent;
        }
#endif
        field(300; "Voucher Message"; Text[250])
        {
            Caption = 'Voucher Message';
            DataClassification = CustomerContent;
        }
        field(301; "Manual Reference number SO"; Boolean)
        {
            Caption = 'Manual Reference number on Sales Orders';
            DataClassification = CustomerContent;
        }
        field(302; "Validate Customer No."; Boolean)
        {
            Caption = 'Validate Customer No.';
            DataClassification = CustomerContent;
        }
        field(330; "Top-up Extends Ending Date"; Boolean)
        {
            Caption = 'Top-up Extends Ending Date';
            DataClassification = CustomerContent;
        }
        field(630; "Voucher Category"; Enum "NPR Voucher Category")
        {
            Caption = 'Voucher Category';
            DataClassification = CustomerContent;
        }
        field(1000; "Voucher Qty. (Open)"; Integer)
        {
            CalcFormula = Count("NPR NpRv Voucher" WHERE("Voucher Type" = FIELD(Code),
                                                      Open = CONST(true)));
            Caption = 'Voucher Qty. (Open)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010; "Voucher Qty. (Closed)"; Integer)
        {
            CalcFormula = Count("NPR NpRv Voucher" WHERE("Voucher Type" = FIELD(Code),
                                                      Open = CONST(false)));
            Caption = 'Voucher Qty. (Closed)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; "Arch. Voucher Qty."; Integer)
        {
            CalcFormula = Count("NPR NpRv Arch. Voucher" WHERE("Voucher Type" = FIELD(Code)));
            Caption = 'Archived Voucher Qty.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1030; "Return Voucher Type"; Code[20])
        {
            Caption = 'Return Voucher Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Ret. Vouch. Type";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    internal procedure DrilldownCalculatedFields(FieldNo: Integer)
    var
        Voucher: Record "NPR NpRv Voucher";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
    begin
        Case FieldNo of
            Rec.FieldNo("Voucher Qty. (Open)"):
                begin
                    Voucher.SetRange("Voucher Type", Rec.Code);
                    Voucher.SetRange(Open, true);
                    Page.Run(0, Voucher);
                end;
            Rec.FieldNo("Voucher Qty. (Closed)"):
                begin
                    Voucher.SetRange("Voucher Type", Rec.Code);
                    Voucher.SetRange(Open, false);
                    Page.Run(0, Voucher);
                end;
            Rec.FieldNo("Arch. Voucher Qty."):
                begin
                    ArchVoucher.SetRange("Voucher Type", Rec.Code);
                    Page.Run(0, ArchVoucher);
                end;
        End;
    end;

#if not BC17
    internal procedure GetStoreCode(): Code[20]
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        exit(CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Store Code"), 1, 20));
    end;

    internal procedure CheckStoreIsAssigned()
    var
        StoreCodeMissingErr: Label 'You must assign a Shopify store to %1 %2.', Comment = '%1 - Table Caption, %2 - Code';
    begin
        if GetStoreCode() = '' then
            Error(StoreCodeMissingErr, TableCaption(), Code);
    end;

    internal procedure CheckVoucherTypeIsNotInUse(NewStoreCode: Code[20])
    var
        StoreCodeMissingErr: Label 'The voucher type has already been assigned to Shopify Store %1 as the type for vouchers sold directly on Shopify. Please remove this association before changing the store.', Comment = '%1 - Shopify store code';
        SpfyStore: Record "NPR Spfy Store";
    begin
        SpfyStore.SetRange("Voucher Type (Sold at Shopify)", Code);
        SpfyStore.SetFilter(Code, '<>%1', NewStoreCode);
        SpfyStore.SetLoadFields(Code);
        if SpfyStore.FindFirst() then
            Error(StoreCodeMissingErr, SpfyStore.Code);
    end;
#endif
}
