# frozen_string_literal: true

require 'benchmark/ips'
require_relative '../config/environment'
require_relative '../app/paths'

Benchmark.ips do |b|
  library_database_repo = RepositoryFactory.library_database
  csv = CSV.read allsearch_path('spec/fixtures/files/libjobs/library-databases.csv'), headers: true
  b.report('LibraryDatabaseRepository#create_from_csv') do
    library_database_repo.create_from_csv csv
    # The deletion should ideally be excluded from the benchmark; it is not what we are trying to measure,
    # but I am not sure how to do that
    library_database_repo.delete
  end
end

Benchmark.ips do |b|
  library_staff_repo = RepositoryFactory.library_staff
  csv = CSV.read Rails.root.join('spec/fixtures/files/library_staff/staff-directory.csv'), headers: true
  b.report('LibraryStaffRepository#new_from_csv') do
    library_staff_repo.new_from_csv csv
    # The deletion should ideally be excluded from the benchmark; it is not what we are trying to measure,
    # but I am not sure how to do that
    library_staff_repo.delete
  end
end

Benchmark.ips do |b|
  long_string = <<~END_LONG_STRING
    •Bayesian networks (BNs) offer an alternative approach to risk estimation.•A BN of mercury risks to panthers replicated traditional probabilistic estimates.•BNs facilitate
    quantification of uncertainty and causal inference.\nTraditionally hazard quotients (HQs) have been computed for ecological risk assessment, often without quantifying the
    underlying uncertainties in the risk estimate. We demonstrate a Bayesian network approach to quantitatively assess uncertainties in HQs using a retrospective case study of
    dietary mercury (Hg) risks to Florida panthers (Puma concolor coryi). The Bayesian network was parameterized, using exposure data from a previous Monte Carlo-based assessment
    of Hg risks (Barron et al., 2004. ECOTOX 13=>223), as a representative example of the uncertainty and complexity in HQ calculations. Mercury HQs and risks to Florida panthers
    determined from a Bayesian network analysis were nearly identical to those determined using the prior Monte Carlo probabilistic assessment and demonstrated the ability of the
    Bayesian network to replicate conventional HQ-based approaches. Sensitivity analysis of the Bayesian network showed greatest influence on risk estimates from daily ingested
    dose by panthers and mercury levels in prey, and less influence from toxicity reference values. Diagnostic inference was used in a high-risk scenario to demonstrate the
    capabilities of Bayesian networks for examining probable causes for observed effects. Application of Bayesian networks in the computation of HQs provides a transparent and
    quantitative analysis of uncertainty in risks."
  END_LONG_STRING
  sanitizer = Sanitizer.new
  b.report('sanitizer') { sanitizer.sanitize long_string }
end
