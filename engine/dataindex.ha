
export type CompanyIndex = struct {
    head: ChunkHeader,

    name_size: u8,
    name: str,

    status: CompanyStatus,
    created_at: i64,
};

export type ContactIndex = struct {
    head: ChunkHeader,

    company_id: u32,

    first_name_size: u8,
    first_name: str,

    last_name_size: u8,
    last_name: str,

    position_size: u8,
    position: str,

    created_at: i64,
};
