table 6150777 "NPR TM RevenuePostingBuffer"
{
    DataClassification = CustomerContent;
    TableType = Temporary;
    Access = Internal;

    fields
    {
        field(1; DeferRevenueProfileCode; Code[10])
        {
            Caption = 'Defer Profile Code';
            DataClassification = CustomerContent;
        }

        field(2; SalesPostingDate; Date)
        {
            Caption = 'Sales Posting Date';
            DataClassification = CustomerContent;
        }
        field(3; AchievedPostingDate; Date)
        {
            Caption = 'Achieved Posting Date';
            DataClassification = CustomerContent;
        }
        field(4; SalesAccount; Code[20])
        {
            Caption = 'Sales Account';
            DataClassification = CustomerContent;
        }
        field(5; AchievedAccount; Code[20])
        {
            Caption = 'Achieved Account';
            DataClassification = CustomerContent;
        }
        field(6; DimensionSetId; Integer)
        {
            Caption = 'Dimension Set Id';
            DataClassification = CustomerContent;
        }
        field(7; SourceDocumentNo; Code[20])
        {
            Caption = 'Source Document No.';
            DataClassification = CustomerContent;
        }
        field(10; DocumentNo; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(20; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; DeferRevenueProfileCode, SalesAccount, AchievedAccount, DimensionSetId, SalesPostingDate, AchievedPostingDate, SourceDocumentNo)
        {
            Clustered = true;
        }
    }

}