export const MAGIC [4]u8 = ['H','U', 'N', 'T'];

export type ChunkHeader = struct {
    chunksize: u32,
    id: u32,
};

export type CompanyStatus = u8 enum {
    PROSPECT,
    CLIENT,
    STALE,
    DEAD,
};

export type OpportunityStage = u8 enum {
    DISCOVERY,
    PROPOSAL,
    NEGOTIATION,
    WON,
    LOST,
};


export type Tag = struct {
    size: u8,
    title: str,
};


export type Company = struct {
    head: ChunkHeader,

    name_size: u8,
    name: str,

    adress_size: u16,
    address: str,

    tags_length: u8,
    tags: []Tag,

    status: CompanyStatus,
    created_at: u64,
};

export type Contact = struct {
    head: ChunkHeader,

    company_id: u32,

    first_name_size: u8,
    first_name: str,

    last_name_size: u8,
    last_name: str,

    email_size: u16,
    email: str,

    phone_size: u8,
    phone: str,

    position_size: u8,
    position: str,
};

export type Action = struct {
    head: ChunkHeader,

    company_id: u32,
    contact_id: u32,
    due_date: u64,

    desc_size: u32,
    desc: str,
};

export type Interaction = struct {
    head: ChunkHeader,
    contact_id: u32,
    action_id: u32,
    date: u64,

    desc_size: u32,
    desc: str,
};

export type Opportunity = struct {
    head: ChunkHeader,

    company_id: u32,
    contact_id: u32,

    value: u32,
    stage: OpportunityStage,
    closing_date: u64,

    title_size: u8,
    title: str,

    desc_size: u32,
    desc: str,
};
