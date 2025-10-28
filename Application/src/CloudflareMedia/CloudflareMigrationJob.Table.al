table 6151245 "NPR CloudflareMigrationJob"
{
    Extensible = false;
    Access = Internal;
    Caption = 'NPR Cloudflare Migration Job';
    DataClassification = CustomerContent;

    fields
    {
        field(1; JobId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Job Id';
        }

        field(2; MediaSelector; Enum "NPR CloudflareMediaSelector")
        {
            DataClassification = CustomerContent;
            Caption = 'Media Selector';
        }

        field(10; EnqueuedCount; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Enqueued Count';
            InitValue = 0;
        }

        field(20; TotalCount; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Count';
            InitValue = 0;
        }

        field(30; SuccessCount; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Success Count';
            InitValue = 0;
        }
        field(40; FailedCount; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Failed Count';
            InitValue = 0;
        }

        field(50; JobCancelled; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Job Cancelled';
            InitValue = false;
        }

        field(60; RateLimitPerSecond; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Rate Limit Per Second';
            InitValue = 10;
        }

        field(90; LimitFetchCount; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Limit Fetch Count';
            MinValue = 1;
            InitValue = 1000;
            Description = 'Specifies the maximum number of items to fetch from Cloudflare in a single request.';
        }
        field(91; NextCursorAfterTs; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Next Cursor After Ts';
            Description = 'Specifies the timestamp to use as a cursor for fetching the next set of items from Cloudflare.';
        }
        field(92; NextCursorAfterRowId; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Next Cursor After Row Id';
            Description = 'Specifies the Row Id to use as a cursor for fetching the next set of items from Cloudflare.';
        }
    }

    keys
    {
        key(Key1; JobId)
        {
            Clustered = true;
        }

        key(Key2; MediaSelector, SystemCreatedAt)
        {
        }
    }


    trigger OnDelete()
    var
        JobLine: Record "NPR CloudflareMigrationJobLine";
    begin
        JobLine.SetFilter(JobId, '=%1', Rec.JobId);
        JobLine.DeleteAll();
    end;

}