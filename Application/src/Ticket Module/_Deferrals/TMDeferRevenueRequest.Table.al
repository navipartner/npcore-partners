table 6150776 "NPR TM DeferRevenueRequest"
{
    DataClassification = CustomerContent;
    Access = Internal;
    Caption = 'Defer Revenue Request (Ticketing)';
    fields
    {
        field(1; TicketAccessEntryNo; Integer)
        {
            Caption = 'Ticket Access Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionMembers = UNRESOLVED,REGISTERED,WAITING,PENDING_DEFERRAL,DEFERRED,IMMEDIATE,DEFERRED_FORCED,DEFERRAL_ABORTED;
            OptionCaption = 'Unresolved,Registered,Waiting,Pending Deferral,Deferred,Immediate,Deferred (Forced),Deferral Aborted';
        }
        field(6; AttemptedRegisterCount; Integer)
        {
            Caption = 'Attempted Register Count';
            DataClassification = CustomerContent;
        }
        field(10; TicketNo; Code[20])
        {
            Caption = 'Ticket No.';
            DataClassification = CustomerContent;
        }
        field(15; ReservationRequestEntryNo; Integer)
        {
            Caption = 'Reservation Request Entry No.';
            DataClassification = CustomerContent;
        }
        field(17; TokenID; Text[100])
        {
            Caption = 'Session Token ID';
            DataClassification = CustomerContent;
        }
        field(18; TokenLineNo; Integer)
        {
            Caption = 'Session Token ID Line No.';
            DataClassification = CustomerContent;
        }
        field(20; AdmissionCode; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
        }
        field(21; ItemNo; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(22; VariantCode; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(23; TicketValidUntil; Date)
        {
            Caption = 'Ticket Valid Until';
            DataClassification = CustomerContent;
        }
        field(25; SalesDate; Date)
        {
            Caption = 'Sales Date';
            DataClassification = CustomerContent;
        }
        field(30; AchievedDate; Date)
        {
            Caption = 'Achieved Date';
            DataClassification = CustomerContent;
        }
        field(40; PaymentOption; Option)
        {
            Caption = 'Payment Option';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Direct,Prepaid,Postpaid,Not Paid';
            OptionMembers = UNKNOWN,DIRECT,PREPAID,POSTPAID,UNPAID;
        }
        field(50; DeferRevenueProfileCode; Code[10])
        {
            Caption = 'Defer Revenue Profile Code';
            DataClassification = CustomerContent;
        }
        field(100; SourceType; Option)
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
            OptionMembers = NA,POS_ENTRY,SALES_DOC;
            OptionCaption = ' ,POS Entry,Sales Document';
        }
        field(110; SourceDocumentNo; Code[20])
        {
            Caption = 'Source Document No.';
            DataClassification = CustomerContent;
        }
        field(120; SourceDocumentLineNo; Integer)
        {
            Caption = 'Source Document Line No.';
            DataClassification = CustomerContent;
        }
        field(125; SourcePostingDate; Date)
        {
            Caption = 'Source Posting Date';
            DataClassification = CustomerContent;
        }
        field(130; ValueEntryNo; Integer)
        {
            Caption = 'Value Entry No.';
            DataClassification = CustomerContent;
        }


        field(200; DimensionSetID; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                // ShowDimensions();
            end;
        }
        field(210; GlobalDimension1Code; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(220; GlobalDimension2Code; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
        }
        field(230; GenBusPostingGroup; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
        }
        field(240; GenProdPostingGroup; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
        }

        field(250; AmountToDefer; Decimal)
        {
            Caption = 'Amount To Defer';
            DataClassification = CustomerContent;
        }

        field(300; DeferralDocumentDate; Date)
        {
            Caption = 'Deferral Document Date';
            DataClassification = CustomerContent;
        }
        field(310; DeferralPostingDate; Date)
        {
            Caption = 'Deferral Posting Date';
            DataClassification = CustomerContent;
        }
        field(320; DeferralDocumentNo; Code[20])
        {
            Caption = 'Deferral Document No';
            DataClassification = CustomerContent;
        }
        field(330; OriginalSalesAccount; Code[20])
        {
            Caption = 'Original Sales Account';
            DataClassification = CustomerContent;
        }
        field(331; AchievedRevenueAccount; Code[20])
        {
            Caption = 'Achieved Revenue Account';
            DataClassification = CustomerContent;
        }
        field(332; InterimAdjustmentAccount; Code[20])
        {
            Caption = 'Interim Adjustment Account';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; TicketAccessEntryNo)
        {
            Clustered = true;
        }

        key(Key2; Status)
        {
        }
        key(Key3; TicketNo, AdmissionCode)
        {
        }
    }

}