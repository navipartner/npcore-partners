#if not BC17
table 6150814 "NPR Spfy C&C Order"
{
    Access = Internal;
    DataClassification = CustomerContent;
    LookupPageId = "NPR Spfy C&C Orders";
    DrillDownPageId = "NPR Spfy C&C Orders";
    Caption = 'Shopify CC Order';

    fields
    {
        field(1; "Order ID"; Code[20])
        {
            Caption = 'Order ID';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Order No."; Integer)
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
        }
        field(10; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
        }
        field(20; "Collect in Store Code"; Code[20])
        {
            Caption = 'Collect in Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Store".Code;
        }
        field(25; "Collect in Store Shopify ID"; Text[30])
        {
            Caption = 'Collect in Store Shopify ID';
            DataClassification = CustomerContent;
        }
        field(30; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(31; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(32; "Customer E-Mail"; Text[80])
        {
            Caption = 'Customer Email';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;
        }
        field(33; "Customer Phone No."; Text[30])
        {
            Caption = 'Customer Phone No.';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;
        }
        field(40; "Np Ec Store Code"; Code[20])
        {
            Caption = 'Np E-commerce Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpEc Store".Code;
        }
        field(50; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(100; "Order Lines"; Blob)
        {
            Caption = 'Order Lines';
            DataClassification = CustomerContent;
        }
        field(200; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionMembers = " ",New,"In-Process","Order Created",Error,Deleted;
            OptionCaption = ' ,New,In-Process,Order Created,Error,Deleted';
        }
        field(210; "Last Error Message"; Blob)
        {
            Caption = 'Last Error Message';
            DataClassification = CustomerContent;
        }
        field(220; "Received from Shopify at"; DateTime)
        {
            Caption = 'Received from Shopify at';
            DataClassification = CustomerContent;
        }
        field(230; "C&C Order Created at"; DateTime)
        {
            Caption = 'CC Order Created at';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Order ID")
        {
            Clustered = true;
        }
        key(Sec1; "Order No.") { }
    }

    trigger OnInsert()
    var
        SpfyCCOrder: Record "NPR Spfy C&C Order";
    begin
        if "Order ID" = '' then begin
            LockTable();
            if SpfyCCOrder.IsEmpty() then
                SpfyCCOrder."Order No." := 1000
            else begin
                SpfyCCOrder.SetCurrentKey("Order No.");
                SpfyCCOrder.FindLast();
                "Order No." := SpfyCCOrder."Order No." + 1;
            end;
            "Order ID" := StrSubstNo('CC-%1', "Order No.");
        end;
        "Received from Shopify at" := CurrentDateTime();
    end;

    trigger OnModify()
    var
        CollectinStoreShopifyIDKeyTxt: Label '''CollectinStoreShopifyID''', Locked = true;
        CustomerNameKeyTxt: Label '''CustomerName''', Locked = true;
        CustomerEmailKeyTxt: Label '''CustomerEmail''', Locked = true;
        CustomerPhoneKeyTxt: Label '''CustomerPhone''', Locked = true;
        MissingKeyValueErr: Label 'Key %1 value must be specified.';
        OrTxt: Label '%1 or %2';
    begin
        if ("Collect in Store Code" = '') and ("Collect in Store Shopify ID" = '') then
            Error(MissingKeyValueErr, CollectinStoreShopifyIDKeyTxt);
        if "Customer Name" = '' then
            Error(MissingKeyValueErr, CustomerNameKeyTxt);
        if ("Customer E-Mail" = '') and ("Customer Phone No." = '') then
            Error(MissingKeyValueErr, StrSubstNo(OrTxt, CustomerEmailKeyTxt, CustomerPhoneKeyTxt));

        if Status = Status::" " then
            Status := Status::New;
    end;

    internal procedure SetOrderLines(NewOrderLines: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Order Lines");
        if NewOrderLines = '' then
            exit;
        "Order Lines".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewOrderLines);
    end;

    procedure GetOrderLinesStream() InStr: InStream
    begin
        CalcFields("Order Lines");
        "Order Lines".CreateInStream(InStr, TextEncoding::UTF8);
    end;

    procedure GetOrderLines(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if not "Order Lines".HasValue then
            exit('');
        exit(TypeHelper.ReadAsTextWithSeparator(GetOrderLinesStream(), TypeHelper.LFSeparator()));
    end;

    internal procedure SetErrorMessage(NewErrorText: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Last Error Message");
        if NewErrorText = '' then
            exit;
        "Last Error Message".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewErrorText);
    end;

    procedure GetErrorMessage(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
        ErrorText: Text;
        NoErrorMessageTxt: Label 'No details were provided for the error.';
    begin
        if Status <> Status::Error then
            exit('');
        ErrorText := '';
        if "Last Error Message".HasValue() then begin
            CalcFields("Last Error Message");
            "Last Error Message".CreateInStream(InStream, TextEncoding::UTF8);
            ErrorText := TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator());
        end;
        if ErrorText = '' then
            ErrorText := NoErrorMessageTxt;
        exit(ErrorText);
    end;
}
#endif