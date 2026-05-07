create extension if not exists "uuid-ossp";

create type venture_state as enum (
  'IDEA_CAPTURED',
  'VALIDATED',
  'BLUEPRINT_GENERATED',
  'MVP_IN_BUILD',
  'MVP_COMPLETED',
  'LAUNCHED',
  'TRACTION_ACTIVE',
  'FUNDRAISING_READY',
  'SCALING'
);

create type execution_task_status as enum ('BLOCKED', 'READY', 'IN_PROGRESS', 'COMPLETED');
create type milestone_status as enum ('LOCKED', 'READY', 'COMPLETED');
create type capital_event_type as enum (
  'VentureCreatedEvent',
  'VentureValidatedEvent',
  'BlueprintGeneratedEvent',
  'MVPBuildStartedEvent',
  'MilestoneCompletedEvent',
  'EquityUpdatedEvent',
  'FinancialModelUpdatedEvent',
  'IntelligenceRecomputedEvent',
  'TransitionBlockedEvent'
);

create table founder_account (
  id uuid primary key default uuid_generate_v4(),
  email text not null unique,
  display_name text not null,
  password_hash text not null,
  created_at timestamptz not null default now()
);

create table venture_object (
  id uuid primary key default uuid_generate_v4(),
  founder_id uuid not null references founder_account(id),
  name text not null,
  current_state venture_state not null default 'IDEA_CAPTURED',
  idea_metadata jsonb not null,
  market_hypothesis jsonb not null,
  business_model jsonb not null,
  mvp_scope jsonb not null,
  team_structure jsonb not null,
  capital_requirement jsonb not null,
  risk_score jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table startup_genome (
  venture_id uuid primary key references venture_object(id) on delete cascade,
  venture_viability int not null check (venture_viability between 0 and 100),
  market_saturation_index int not null check (market_saturation_index between 0 and 100),
  execution_complexity_index int not null check (execution_complexity_index between 0 and 100),
  funding_probability int not null check (funding_probability between 0 and 100),
  expected_time_to_mvp_weeks int not null,
  risk_failure_probability int not null check (risk_failure_probability between 0 and 100),
  scope_directive text not null,
  updated_at timestamptz not null default now()
);

create table execution_task (
  id uuid primary key default uuid_generate_v4(),
  venture_id uuid not null references venture_object(id) on delete cascade,
  external_key text not null,
  title text not null,
  owner_logic text not null,
  status execution_task_status not null default 'BLOCKED',
  required_evidence jsonb not null default '[]',
  submitted_evidence jsonb not null default '[]',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (venture_id, external_key)
);

create table venture_milestone (
  id uuid primary key default uuid_generate_v4(),
  venture_id uuid not null references venture_object(id) on delete cascade,
  external_key text not null,
  title text not null,
  required_state venture_state not null,
  status milestone_status not null default 'LOCKED',
  required_evidence jsonb not null default '[]',
  unique (venture_id, external_key)
);

create table equity_structure (
  venture_id uuid primary key references venture_object(id) on delete cascade,
  founder_equity numeric(6,3) not null,
  algoforce_equity numeric(6,3) not null,
  vesting_months int not null default 24,
  cliff_months int not null default 6,
  elapsed_months int not null default 0,
  unlocked_algoforce_equity numeric(6,3) not null default 0,
  unlock_rules jsonb not null,
  check (founder_equity + algoforce_equity = 100)
);

create table equity_ledger (
  id uuid primary key default uuid_generate_v4(),
  venture_id uuid not null references venture_object(id) on delete cascade,
  event_type capital_event_type not null,
  party text not null,
  equity_percent numeric(6,3) not null,
  payload jsonb not null default '{}',
  created_at timestamptz not null default now()
);

create table financial_model (
  venture_id uuid primary key references venture_object(id) on delete cascade,
  projected_monthly_revenue numeric(14,2) not null,
  monthly_burn numeric(14,2) not null,
  break_even_month int not null,
  funding_requirement numeric(14,2) not null,
  valuation_estimate numeric(14,2) not null,
  updated_at timestamptz not null default now()
);

create table network_effect_model (
  venture_id uuid primary key references venture_object(id) on delete cascade,
  investor_mapping_score int not null,
  talent_match_score int not null,
  similarity_graph_score int not null,
  recommended_investor_profiles jsonb not null default '[]',
  required_talent_signals jsonb not null default '[]'
);

create table capital_event_log (
  id uuid primary key default uuid_generate_v4(),
  venture_id uuid references venture_object(id) on delete cascade,
  event_type capital_event_type not null,
  message text not null,
  payload jsonb not null default '{}',
  created_at timestamptz not null default now()
);

create index idx_venture_founder on venture_object(founder_id);
create index idx_venture_state on venture_object(current_state);
create index idx_task_venture_status on execution_task(venture_id, status);
create index idx_event_venture_created on capital_event_log(venture_id, created_at desc);

create or replace function prevent_event_mutation()
returns trigger as $$
begin
  raise exception 'CapitalOS event and equity logs are append-only';
end;
$$ language plpgsql;

create trigger capital_event_log_append_only
before update or delete on capital_event_log
for each row execute function prevent_event_mutation();

create trigger equity_ledger_append_only
before update or delete on equity_ledger
for each row execute function prevent_event_mutation();
