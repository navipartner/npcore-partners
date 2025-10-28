interface "NPR CloudflareMigrationInterface"
{
    procedure PublicIdLookup(PublicId: Text[100]; var TableNumber: Integer; var SystemId: Guid): Boolean;
}