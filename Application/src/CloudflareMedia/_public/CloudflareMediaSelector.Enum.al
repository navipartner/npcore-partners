enum 6059923 "NPR CloudflareMediaSelector" implements "NPR CloudflareMigrationInterface"
{
    Extensible = true;

    value(0; NOOP)
    {
        Caption = '';
        Implementation = "NPR CloudflareMigrationInterface" = "NPR CloudflareMediaImpl";
    }

    value(100; MEMBER_PHOTO)
    {
        Caption = 'Member Photo';
        Implementation = "NPR CloudflareMigrationInterface" = "NPR MMMemberImageMediaHandler";
    }
}