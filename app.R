library(shiny)
library(DT)
library(shinydashboard)

input_help <- function(input_ui, help_text) {
  div(
    input_ui,
    tags$small(
      help_text,
      style = "display:block; color:#6c757d; margin-top:-10px; margin-bottom:15px;"
    )
  )
}

# Fill in the official links and paper citation when available.
# Leave a URL empty to show a clear placeholder in the About tab.
gnext_pipeline_github <- "https://github.com/DyHealthNet/gnext_nf_pipeline"
gnext_platform_github <- "https://github.com/DyHealthNet/gnext_platform/tree/main"
gnext_pipeline_issues <- "https://github.com/DyHealthNet/gnext_nf_pipeline/issues"
gnext_platform_issues <- "https://github.com/DyHealthNet/gnext_platform/issues"
gnext_paper_url <- "https://doi.org/10.1038/s41588-026-02708-6"
gnext_paper_citation <- "Arend, L., Woller, F., Rehor, B. et al. Bridging the gap between GWAS and network medicine with GNExT. Nat Genet (2026)."

about_resource <- function(label, url) {
  if (nzchar(trimws(url))) {
    tags$a(label, href = url, target = "_blank", rel = "noopener noreferrer")
  } else {
    tags$span(paste0(label, " (link to be added)"), style = "color:#777;")
  }
}

ui <-  dashboardPage(
  dashboardHeader(
    title = tags$img(src = "gnext_logo.png", alt = "GNExT - GWAS Network Exploration Tool",
                     class = "gnext-header-logo")
  ),
  title = "GNExT - GWAS Network Exploration Tool",
  
  dashboardSidebar(
    sidebarMenu(
      menuItem(
        "Nextflow pipeline",
        tabName = "preprocessing",
        icon = icon("gears")
      ),
      menuItem(
        "Platform",
        tabName = "platform",
        icon = icon("globe")
      ),
      menuItem(
        "About",
        tabName = "about",
        icon = icon("info-circle")
      ),
      menuItem(
        "Citation",
        tabName = "citation",
        icon = icon("quote-right")
      ),
      menuItem(
        "Issues",
        tabName = "issues",
        icon = icon("bug")
      )
    )
  ),
  dashboardBody(
    tags$head(tags$style(HTML("
      /* GNExT brand color: override the default shinydashboard blue skin. */
      .skin-blue .main-header .navbar,
      .skin-blue .main-header .logo,
      .skin-blue .main-header .logo:hover,
      .skin-blue .main-header .navbar .sidebar-toggle:hover {
        background-color: #95AAD3 !important;
      }
      .skin-blue .main-header .navbar .sidebar-toggle,
      .skin-blue .main-header .logo { color: #172B4D !important; }
      .skin-blue .sidebar-menu > li.active > a {
        border-left-color: #95AAD3 !important;
      }
      .content-wrapper, .right-side { background-color: #fff !important; }
      .main-header .logo .gnext-header-logo {
        width: 142px; max-height: 35px; object-fit: contain;
        vertical-align: middle;
      }
    "))),
    tabItems(
      
      tabItem(
        tabName = "preprocessing",
        
        h2("Nextflow Preprocessing Pipeline for a GNExT Platform"),
  
      tabsetPanel(
        
        tabPanel(
          "Phenotype metadata table",
          
          sidebarLayout(
            sidebarPanel(
              input_help(
                textInput("phenocode", "Phenocode", placeholder = "coffee_wk"),
                "Unique identifier of the phenotype or trait."
              ),
              
              input_help(
                textInput("description", "Description", placeholder = "coffee_wk"),
                "Description of the phenotype or trait."
              ),
              
              input_help(
                textInput("category", "Category", placeholder = "weekly assumption of coffee"),
                "Group or category of the phenotype.  Commas are not allowed."
              ),
              
              input_help(
                textInput("filename", "GWAS file path", placeholder = "/path/to/sumstats/coffee_wk.regenie.gz"),
                "Absolute path to the GWAS summary statistics file."
              ),
              
              input_help(
                numericInput("nr_samples", "Number of samples (Optional)", value = NA, min = 1),
                "Number of samples included in the GWAS."
              ),
              
              actionButton("add_row", "Add row"),
              hr(),
              input_help(
                textInput("phenotype_table_path", "Existing phenotype metadata table path", placeholder = "/path/to/phenotypes.csv"),
                "Absolute path to a CSV or TSV file accessible from the Shiny server. Loading replaces the current table."
              ),
              actionButton("load_phenotype_table", "Load table")
            ),
            
            mainPanel(
              h3("Phenotype metadata table"),
              
              p("The primary input to the preprocessing pipeline is a CSV/TSV file containing the phenotypes and their corresponding GWAS summary statistics file locations."),
              
              p("Each row represents one phenotype, with the following columns:"),
              
              DTOutput("phenotype_table"),
              br(),
              actionButton("delete_row", "Delete selected row", class = "btn-danger")
            )
          )
        ),
        
        tabPanel(
          "Study-specific config",
          
          h3("Study-specific config"),
          
          p("Study-specific parameters must be defined in the configuration file configs/study_specific.config."),
          
          fluidRow(
            column(
              6,
              
              input_help(
                textInput("base_dir", "base_dir", placeholder = "path/to/sumstats"),
                "Path to the base directory containing the GWAS summary statistic files."
              ),
              
              input_help(
                numericInput("pheno_batch_size", "pheno_batch_size", value = 5),
                "Number of phenotypes processed in parallel within a single batch."
              ),
              
              input_help(
                numericInput("window_up", "window_up", value = 10),
                "Upstream window size in kb used when mapping variants to genes in MAGMA."
              ),
              
              input_help(
                numericInput("window_down", "window_down", value = 10),
                "Downstream window size in kb used when mapping variants to genes in MAGMA."
              ),
              
              input_help(
                textInput("gene_location", "gene_location", placeholder = "/path/to/ensembl_annotations/homo_sapiens_grch38_release_115.tsv"),
                "Path to the Ensembl gene location file used for MAGMA analyses."
              ),
              
              input_help(
                textInput("steps", "steps", value = '["gene_statistics", "gwas_exploration"]'),
                "List of workflow steps to be executed."
              )
            ),
            
            column(
              6,
              
              h4("GWAS column indices"),
              
              fluidRow(
                column(3, input_help(numericInput("chr_column", "chr", value = 1), "Chromosome column")),
                column(3, input_help(numericInput("pos_column", "pos", value = 2), "Position column")),
                column(3, input_help(numericInput("ref_column", "ref", value = 4), "Reference allele")),
                column(3, input_help(numericInput("alt_column", "alt", value = 5), "Alternate allele"))
              ),
              
              fluidRow(
                column(3, input_help(numericInput("pval_column", "pval", value = 22), "P-value column")),
                column(3, input_help(numericInput("beta_column", "beta", value = 19), "Effect size")),
                column(3, input_help(numericInput("se_column", "se", value = 20), "Standard error")),
                column(3, input_help(numericInput("af_column", "af", value = 6), "Allele frequency"))
              ),
              
              input_help(
                numericInput("n_samples_column", "n_samples_column", value = 8, min = 1),
                "Column containing the sample count in the GWAS summary statistics. Required when Number of samples is not provided."
              ),
              
              br(),
              
              input_help(
                selectInput("pval_neglog10", "pval_neglog10", choices = c("false", "true"), selected = "true"),
                "Whether p-values are stored as -log10 or raw."
              ),
              
              input_help(
                textInput("ensemblvep_species", "ensemblvep_species", value = "homo_sapiens"),
                "Species identifier for Ensembl VEP annotation."
              ),
              
              input_help(
                textInput("ensemblvep_genome", "ensemblvep_genome", value = "GRCh38"),
                "Genome assembly version."
              ),
              
              input_help(
                numericInput("ensemblvep_cache_version", "ensemblvep_cache_version", value = 115),
                "VEP cache version."
              ),
              
              input_help(
                textInput("ensemblvep_cache", "ensemblvep_cache", placeholder = "/path/to/VEP/"),
                "Optional VEP cache path."
              ),
              
              input_help(
                textInput("magma_reference_plink", "magma_reference_plink", placeholder = "/path/to/ref_panel_chr"),
                "PLINK reference panel."
              )
            )
          )
        ),
        
        tabPanel(
          "Compute SLURM config",
          
          h3("Compute SLURM config"),
          
          p("Computational settings such as memory allocation, runtime limits, and scheduler-related parameters should be specified in configs/compute.config."),
          
          fluidRow(
            column(
              6,
              input_help(textInput("slurm_queue", "slurm_queue", value = "computational"), "SLURM queue used when profile = slurm."),
              input_help(numericInput("global_maxForks", "global_maxForks", value = 10), "Maximum number of processes that can run in parallel."),
              input_help(numericInput("normalize_cpus", "normalize_cpus", value = 12), "CPU cores allocated for normalization."),
              input_help(textInput("normalize_memory", "normalize_memory", value = "64GB"), "Memory allocated for normalization."),
              input_help(numericInput("vcf_cpus", "vcf_cpus", value = 16), "CPU cores allocated for variant annotation and processing."),
              input_help(textInput("vcf_memory", "vcf_memory", value = "64GB"), "Memory allocated for VCF processing and annotation."),
              input_help(numericInput("manhattan_qq_cpus", "manhattan_qq_cpus", value = 12), "CPU cores used for Manhattan and QQ plot generation."),
              input_help(textInput("manhattan_qq_memory", "manhattan_qq_memory", value = "64GB"), "Memory allocated for Manhattan and QQ plot generation.")
            ),
            
            column(
              6,
              input_help(numericInput("chrom_bgz_maxForks", "chrom_bgz_maxForks", value = 23), "Maximum number of chromosome compression tasks running simultaneously."),
              input_help(textInput("chrom_bgz_memory", "chrom_bgz_memory", value = "64GB"), "Memory allocated for per-chromosome compression tasks."),
              input_help(numericInput("chrom_bgz_cpus", "chrom_bgz_cpus", value = 8), "CPU cores allocated for per-chromosome compression tasks."),
              input_help(numericInput("magma_cpus", "magma_cpus", value = 32), "CPU cores allocated for MAGMA gene-based analyses."),
              input_help(textInput("magma_memory", "magma_memory", value = "64GB"), "Memory allocated for MAGMA analyses."),
              input_help(numericInput("magma_input_cpus", "magma_input_cpus", value = 32), "CPU cores allocated for preparing MAGMA input files."),
              input_help(textInput("magma_input_memory", "magma_input_memory", value = "64GB"), "Memory allocated for MAGMA input file preparation.")
            )
          )
        ),
        
        tabPanel(
          "Base config",
          
          h3("Base config"),
          
          p("These parameters are typically not intended to be modified."),
          
          fluidRow(
            column(
              6,
              input_help(numericInput("manhattan_num_unbinned", "manhattan_num_unbinned", value = 500), "Number of unbinned variants displayed in the Manhattan plot."),
              input_help(numericInput("manhattan_peak_max_count", "manhattan_peak_max_count", value = 500), "Maximum number of peaks displayed in the Manhattan plot."),
              input_help(textInput("manhattan_peak_pval_threshold", "manhattan_peak_pval_threshold", value = "1e-6"), "P-value threshold for identifying peaks."),
              input_help(textInput("manhattan_peak_sprawl_dist", "manhattan_peak_sprawl_dist", value = "200000"), "Minimum genomic distance required to distinguish separate peaks.")
            ),
            
            column(
              6,
              input_help(textInput("top_hits_pval_cutoff", "top_hits_pval_cutoff", value = "1e-6"), "P-value threshold used to select top associated variants."),
              input_help(textInput("top_hits_max_limit", "top_hits_max_limit", value = "10000"), "Maximum number of top associated variants reported."),
              input_help(textInput("ensemblvep_distance_up", "ensemblvep_distance_up", value = "5000"), "Upstream distance in base pairs used by Ensembl VEP."),
              input_help(textInput("ensemblvep_distance_down", "ensemblvep_distance_down", value = "5000"), "Downstream distance in base pairs used by Ensembl VEP.")
            )
          )
        ),
        
        tabPanel(
          "Run pipeline",
          
          h3("Create job files and submit pipeline"),
          
          input_help(
            textInput("pipeline_dir", "Pipeline directory", placeholder = "/path/to/gnext_nf_pipeline"),
            "Path to the cloned GNExT Nextflow pipeline repository."
          ),
          
          input_help(
            textInput("job_dir", "Job directory", placeholder = "/path/to/job_dir"),
            "Directory where the app will save phenotype metadata, config files, logs, work directory and results."
          ),
          
    
          h4("Java and Nextflow (installed on the HPC cluster)"),
          input_help(
            textInput("java_home", "Java home directory", placeholder = "/shared/software/jdk-21"),
            "Directory containing bin/java; must be accessible to the SLURM job."
          ),
          input_help(
            textInput("nextflow_path", "Nextflow executable path", placeholder = "/shared/software/nextflow"),
            "Full path to the Nextflow executable, accessible to the SLURM job."
          ),
          helpText("Conda environments are created automatically by Nextflow."),

          actionButton("create_job_files", "Create config files"),
          br(), br(),
          actionButton("run_pipeline", "Submit pipeline", class = "btn-primary"),
          br(), br(),
          
          verbatimTextOutput("run_status")
        )
      )
    ),
    tabItem(
      tabName = "platform",
      
      h2("GNExT Platform Environment Configuration"),
      
      tabsetPanel(
        tabPanel(
          "Platform inputs",
          
          fluidRow(
            column(
              6,
              
              h3("Study Identifier for Deployment"),
              
              input_help(
                textInput("platform_STUDY_ACRONYM", "STUDY_ACRONYM", placeholder = "your_study"),
                "Used for container names and network. No spaces, lowercase recommended."
              ),
              
              h3("Study Name and Genome Build"),
              
              input_help(
                textInput("platform_VITE_STUDY_NAME", "VITE_STUDY_NAME", placeholder = "Your Study Name"),
                "Display name for your study in the home page."
              ),
              
              input_help(
                selectInput(
                  "platform_VITE_GENOME_BUILD",
                  "VITE_GENOME_BUILD",
                  choices = c("GRCh37", "GRCh38"),
                  selected = "GRCh38"
                ),
                "Genome build version."
              ),
              
              input_help(
                numericInput("platform_VITE_HG_BUILD_NUMBER", "VITE_HG_BUILD_NUMBER", value = 38),
                "Human genome build number: 19 for GRCh37, 38 for GRCh38."
              ),
              
              h3("Study-Specific Data Paths"),
              
              input_help(
                textInput("platform_PHENO_FILE", "PHENO_FILE", placeholder = "/path/to/pheno_file.csv"),
                "Path to phenotype CSV file."
              ),
              
              input_help(
                textInput("platform_NF_DATA_DIR", "NF_DATA_DIR", placeholder = "/path/to/nf_output/"),
                "Directory containing Nextflow pipeline output."
              ),
              
              h3("Example Data for UI Demonstrations"),
              
              input_help(
                textInput("platform_VITE_TRAIT_EXAMPLE", "VITE_TRAIT_EXAMPLE", placeholder = "trait_id"),
                "Example trait ID for search demonstrations."
              ),
              
              input_help(
                textInput("platform_VITE_VARIANT_EXAMPLE", "VITE_VARIANT_EXAMPLE", placeholder = "1_12345678_A/G"),
                "Example variant ID. Format: chr_pos_ref/alt."
              ),
              
              input_help(
                textInput("platform_VITE_GENE_EXAMPLE", "VITE_GENE_EXAMPLE", placeholder = "ENSG00000000001"),
                "Example gene ID for search demonstrations."
              )
            ),
            
            column(
              6,
              
              h3("Citation Information"),
              
              input_help(
                textAreaInput(
                  "platform_VITE_STUDY_BIBTEX_CITATION",
                  "VITE_STUDY_BIBTEX_CITATION",
                  placeholder = '@article{your_study_2025,
  title = {Your Study Title},
  journal = {Your Journal},
  author = {Your Author List},
  year = {2025},
  doi = {10.xxxx/your.doi}
}',
                  rows = 8
                ),
                "BibTeX citation."
              ),
              
              input_help(
                textAreaInput(
                  "platform_VITE_STUDY_PLAIN_CITATION",
                  "VITE_STUDY_PLAIN_CITATION",
                  placeholder = "Your Author et al. Your Study Title. Your Journal (2025). https://doi.org/10.xxxx/your.doi",
                  rows = 3
                ),
                "Plain text citation."
              ),
              
              input_help(
                textInput(
                  "platform_VITE_STUDY_CITATION_DOI_LINK",
                  "VITE_STUDY_CITATION_DOI_LINK",
                  placeholder = "https://doi.org/10.xxxx/your.doi"
                ),
                "DOI link."
              )
            )
          ),
          
          fluidRow(
            column(
              6,
              
              h3("Feature Configuration"),
              
              input_help(
                selectInput(
                  "platform_VITE_MAGMA_SHOW",
                  "VITE_MAGMA_SHOW",
                  choices = c("true", "false"),
                  selected = "true"
                ),
                "Show MAGMA gene-based analysis. If true, MAGMA data must be available from the Nextflow output."
              ),
              
              input_help(
                selectInput(
                  "platform_VITE_GENE_ID_SPACE",
                  "VITE_GENE_ID_SPACE",
                  choices = c("symbol", "ensembl"),
                  selected = "symbol"
                ),
                "Gene ID format."
              ),
              
              input_help(
                textInput("platform_VITE_TRAIT_EXTERNAL_REF_URL", "VITE_TRAIT_EXTERNAL_REF_URL", value = ""),
                "Optional external reference URL for traits."
              ),
              
              h3("MAGMA Analysis Configuration"),
              
              input_help(
                textInput("platform_MAGMA_REF_POPULATION", "MAGMA_REF_POPULATION", placeholder = "TOPMed"),
                "Reference population used for MAGMA analysis."
              ),
              
              input_help(
                textInput("platform_MAGMA_REF_GENE_LOCATION", "MAGMA_REF_GENE_LOCATION", placeholder = "Ensembl v115"),
                "Gene location annotation version used for MAGMA."
              )
            ),
            
            column(
              6,
              
              h3("Typesense Search Configuration"),
              
              input_help(
                tagList(
                  textInput(
                    "platform_VITE_TYPESENSE_KEY",
                    "VITE_TYPESENSE_KEY",
                    value = "your_secure_typesense_api_key_here"
                  ),
                  div(
                    style = "margin-bottom: 10px;",
                    actionButton("generate_typesense_key", "Generate random key")
                  )
                ),
                "Typesense API key."
              ),
              
              input_help(
                numericInput("platform_VITE_TYPESENSE_PORT", "VITE_TYPESENSE_PORT", value = 8108),
                "Typesense port. Must be unique if running multiple studies."
              ),
              
              input_help(
                textInput("platform_TYPESENSE_VOLUME_DIR", "TYPESENSE_VOLUME_DIR", placeholder = "/path/to/typesense_volume"),
                "Directory for Typesense data persistence."
              ),
              
              input_help(
                selectInput(
                  "platform_FORCE_TYPESENSE_RESET",
                  "FORCE_TYPESENSE_RESET",
                  choices = c("false", "true"),
                  selected = "false"
                ),
                "Force data re-import on startup."
              )
            )
          ),
          
          fluidRow(
            column(
              6,
              
              h3("UI Theming"),
              
              input_help(
                textInput("platform_VITE_COLOR_PRIMARY", "VITE_COLOR_PRIMARY", value = "#1976D2"),
                "Primary theme color."
              ),
              
              input_help(
                textInput("platform_VITE_COLOR_PRIMARY_DARK", "VITE_COLOR_PRIMARY_DARK", value = "#1565C0"),
                "Primary dark theme color."
              )
            ),
            
            column(
              6,
              
              h3("Ports and Processing"),
              
              input_help(
                numericInput("platform_VITE_BACKEND_PORT", "VITE_BACKEND_PORT", value = 8000),
                "Backend API port. Must be unique if running multiple studies."
              ),
              
              input_help(
                numericInput("platform_VITE_FRONTEND_PORT", "VITE_FRONTEND_PORT", value = 80),
                "Frontend port for production Docker."
              ),
              
              input_help(
                numericInput("platform_BATCH_SIZE", "BATCH_SIZE", value = 100000),
                "Batch size for data import operations."
              )
            )
          ),
          
          hr(),
          
          h3("Save .env file and create Docker launch script"),
          
          input_help(
            textInput("platform_env_dir", "Output directory", placeholder = "/path/to/job_dir"),
            "Directory where the .env file will be saved."
          ),
          
          input_help(
            textInput(
              "platform_repo_dir",
              "GNExT platform repository directory",
              placeholder = "/path/to/gnext_platform"
            ),
            "Path to the cloned GNExT platform repository."
          ),
          
          actionButton("create_env_file", "Create .env file and Docker script", class = "btn-primary"),
          br(), br(),
          
          verbatimTextOutput("platform_status")
        )
      )
    ),
    tabItem(
      tabName = "about",
      div(
        style = "max-width:960px; padding-bottom:42px;",
        div(
          style = "text-align:left; margin:4px 0 26px;",
          tags$img(src = "gnext_logo.png", alt = "GNExT - GWAS Network Exploration Tool",
                   style = "width:480px; max-width:95%; height:auto;")
        ),
        h2("GNExT - GWAS Network Exploration Tool"),
        p("A web-based platform that builds on PheWeb’s interactive, scalable, and decentralized deployment model while extending its functionalities beyond a variant-level effect and significance exploration towards a systems and network medicine toolbox."),
        p("By including MAGMA and DrugSt.One, GNExT allows its users to study genetic variants on the network level down to the identification of potential drug repurposing candidates. Our solution advances over the current state of the art platform PheWeb by offering a highly standardized Nextflow pipeline for data import and processing, allowing researchers to easily deploy their study results on a web interface."),
        p("For further information, see the ", about_resource("GNExT Platform README on GitHub", gnext_platform_github), "."),
        div(
          style = "margin:22px 0 28px; text-align:left;",
          tags$img(src = "gnext_overview.png", alt = "GNExT overview: GWAS data, preprocessing pipeline, web platform and network medicine",
                   style = "display:block; width:100%; max-width:100%; height:auto;"),
          tags$small(tags$em("Overview of the GNExT Tool"), style = "display:block; margin-top:8px; color:#666;")
        ),
        hr(),
        h3("What does this Shiny application do?"),
        p("This Shiny application supports two consecutive stages: (1) configuring and submitting the GNExT Nextflow data preprocessing pipeline, and (2) configuring the GNExT web platform to explore the processed results."),
        h3("1. Data Preprocessing - Nextflow Pipeline"),
        p("Data preprocessing for a GNExT platform is performed through a Nextflow-based pipeline that enables seamless deployment across different computing environments and automatically ensures scalability for large collections of GWAS summary statistics."),
        p("Please refer to GitHub repository of the preprocessing pipeline for detailed explanation of all required parameters: ", about_resource("gnext_nf_pipeline", gnext_pipeline_github), "."),
        div(
          style = "margin:18px 0 24px; text-align:left;",
          tags$img(src = "gnext_pipeline_overview.png", alt = "GNExT Nextflow Pipeline logo",
                   style = "display:block; width:440px; max-width:85%; height:auto;"),
          tags$small(tags$em("Data Preprocessing Pipeline for GNExT Platform"), style = "display:block; margin-top:8px; color:#666;")
        ),
        tags$ol(
          tags$li(tags$b("Phenotype metadata table: "),
                  "Add phenotype records manually or load an existing CSV/TSV file using a path accessible to the Shiny server. Review the table before continuing."),
          tags$li(tags$b("Study-specific config: "),
                  "Set GWAS input paths, column indices, genome build, reference resources and workflow steps."),
          tags$li(tags$b("Compute SLURM config: "),
                  "Adjust partition, concurrency, CPU and memory settings for your HPC cluster."),
          tags$li(tags$b("Base config: "),
                  "Review the analysis and visualization parameters if needed."),
          tags$li(tags$b("Run pipeline: "),
                  "Specify the pipeline and job directories, Java home and Nextflow executable. Click 'Create config files', then 'Submit pipeline'.")
        ),
        h3("2. GNExT platform configuration"),
        p("After preprocessing has completed, use the 'Platform' tab to prepare the study-specific deployment configuration."),
        hr(),
        h3("Documentation and source code"),
        p("For complete setup instructions, pipeline parameters, deployment requirements and troubleshooting, consult the GitHub documentation:"),
        tags$ul(
          tags$li(about_resource("GNExT Platform - README and source code", gnext_platform_github)),
          tags$li(about_resource("GNExT Nextflow preprocessing pipeline - README and source code", gnext_pipeline_github))
        ),
        tags$small("Please refer to the GitHub repositories for detailed documentation and deployment requirements.",
                   style = "color:#666;")
      )
    ),
    tabItem(
      tabName = "citation",
      div(
        style = "max-width:960px; padding-bottom:42px;",
        h2("Citation"),
        p("If you use GNExT in your research, please cite:"),
        p(if (nzchar(trimws(gnext_paper_citation))) gnext_paper_citation else
            "GNExT publication: add the verified paper citation (authors, title, journal, year and DOI) in the app configuration."),
        p(about_resource("GNExT paper", gnext_paper_url))
      )
    ),
    tabItem(
      tabName = "issues",
      div(
        style = "max-width:960px; padding-bottom:42px;",
        h2("Issues"),
        p("If you run into trouble, find a bug or have a feature request, please check the existing issues or open a new one in the corresponding GitHub repository:"),
        tags$ul(
          tags$li(tags$b("Nextflow pipeline: "),
                  "problems with preprocessing, pipeline parameters or job submission - ",
                  about_resource("gnext_nf_pipeline issues", gnext_pipeline_issues)),
          tags$li(tags$b("Platform: "),
                  "problems with the platform configuration, deployment or web interface - ",
                  about_resource("gnext_platform issues", gnext_platform_issues))
        ),
        p("When opening an issue, please describe what you did, what you expected to happen and include any error messages or log output.")
      )
    )
  )
)
)

server <- function(input, output, session) {
  
  table_data <- reactiveVal(data.frame(
    phenocode = character(),
    description = character(),
    category = character(),
    filename = character(),
    nr_samples = numeric(),
    stringsAsFactors = FALSE
  ))
  
  observeEvent(input$load_phenotype_table, {
    path <- trimws(input$phenotype_table_path)
    tryCatch({
      if (!nzchar(path)) stop("Specify a CSV or TSV file path.")
      if (!file.exists(path) || dir.exists(path)) stop("File does not exist or is not a regular file.")
      path <- normalizePath(path, mustWork = TRUE)
      if (!grepl("\\.(csv|tsv)$", path, ignore.case = TRUE)) stop("Only .csv and .tsv files are supported.")
      separator <- if (grepl("\\.tsv$", path, ignore.case = TRUE)) "\t" else ","
      df <- read.table(path, header = TRUE, sep = separator, quote = "\"", comment.char = "", check.names = FALSE,
                       stringsAsFactors = FALSE, fill = FALSE, na.strings = c("", "NA"))
      required <- c("phenocode", "description", "category", "filename")
      if (!all(required %in% names(df))) {
        stop(paste("Missing required columns:", paste(setdiff(required, names(df)), collapse = ", ")))
      }
      if (anyDuplicated(names(df))) stop("Duplicate column names are not allowed.")
      if (nrow(df) == 0) stop("The file contains no phenotype rows.")
      if (anyNA(df[required]) || any(!nzchar(trimws(as.character(unlist(df[required])))))) {
        stop("Required phenotype columns cannot contain empty values.")
      }
      if (!"nr_samples" %in% names(df)) df$nr_samples <- NA_real_
      if (any(!is.na(df$nr_samples) & (!grepl("^[0-9]+$", as.character(df$nr_samples)) | suppressWarnings(as.numeric(df$nr_samples)) <= 0))) {
        stop("nr_samples must contain positive integers or be empty.")
      }
      df$nr_samples <- as.numeric(df$nr_samples)
      df <- df[c(required, "nr_samples")]
      table_data(df)
      showNotification(sprintf("Loaded %d phenotypes from %s. Review the table below.", nrow(df), basename(path)), type = "message")
    }, error = function(e) {
      showNotification(paste("Could not load phenotype table:", conditionMessage(e)), type = "error", duration = NULL)
    })
  })

  observeEvent(input$add_row, {
    new_row <- data.frame(
      phenocode = input$phenocode,
      description = input$description,
      category = input$category,
      filename = input$filename,
      nr_samples = input$nr_samples,
      stringsAsFactors = FALSE
    )
    
    table_data(rbind(table_data(), new_row))
  })
  
  output$phenotype_table <- renderDT({
    datatable(
      table_data(),
      editable = TRUE,
      rownames = FALSE,
      options = list(pageLength = 10)
    )
  })
  
  observeEvent(input$phenotype_table_cell_edit, {
    info <- input$phenotype_table_cell_edit
    df <- table_data()
    df[info$row, info$col + 1] <- info$value
    table_data(df)
  })
  
  observeEvent(input$delete_row, {
    selected <- input$phenotype_table_rows_selected
    if (length(selected) > 0) {
      df <- table_data()
      table_data(df[-selected, , drop = FALSE])
    }
  })
  
  quote_nf <- function(x) {
    shQuote(x, type = "sh")
  }
  
  write_config <- function(file, values) {
    lines <- paste0("params.", names(values), " = ", values)
    writeLines(lines, file)
  }
  
  create_job_files <- function() {
    
    if (nrow(table_data()) == 0) {
      stop("Phenotype metadata table is empty. Please add at least one row.")
    }
    
    
    if (!dir.exists(input$pipeline_dir)) {
      stop("Pipeline directory does not exist.")
    }
    
    job_dir <- normalizePath(input$job_dir, mustWork = FALSE)
    pipeline_dir <- normalizePath(input$pipeline_dir, mustWork = TRUE)
    if (identical(job_dir, pipeline_dir) || startsWith(job_dir, paste0(pipeline_dir, "/"))) {
      stop("Job directory must be outside the shared pipeline repository.")
    }
    if (!file.exists(file.path(pipeline_dir, "main.nf")) ||
        !file.exists(file.path(pipeline_dir, "nextflow.config"))) {
      stop("Pipeline directory must contain main.nf and nextflow.config.")
    }
    
    configs_dir <- file.path(job_dir, "configs")
    logs_dir <- file.path(job_dir, "logs")
    results_dir <- file.path(job_dir, "nf_output")
    work_dir <- file.path(job_dir, "work")
    
    dir.create(job_dir, recursive = TRUE, showWarnings = FALSE)
    dir.create(configs_dir, recursive = TRUE, showWarnings = FALSE)
    dir.create(logs_dir, recursive = TRUE, showWarnings = FALSE)
    dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)
    dir.create(work_dir, recursive = TRUE, showWarnings = FALSE)
    if (!dir.exists(configs_dir)) stop("Cannot create job-specific configs directory.")
    
    pheno_file <- file.path(job_dir, "pheno_file.csv")
    
    df <- table_data()
    
    nr_samples_missing <- is.na(df$nr_samples) | trimws(as.character(df$nr_samples)) == ""
    n_samples_column_missing <- is.null(input$n_samples_column) || is.na(input$n_samples_column)
    
    if (any(nr_samples_missing) && n_samples_column_missing) {
      stop("Number of samples must be provided for every phenotype unless n_samples_column is specified.")
    }
    
    n_samples_column_value <- if (n_samples_column_missing) "null" else input$n_samples_column
    
    if ("nr_samples" %in% colnames(df) && all(nr_samples_missing)) {
      df$nr_samples <- NULL
    }
    
    write.table(
      df,
      pheno_file,
      sep = ",",
      row.names = FALSE,
      quote = FALSE
    )
    
    write_config(
      file.path(configs_dir, "study_specific.config"),
      list(
        pheno_file = quote_nf(pheno_file),
        base_dir = quote_nf(input$base_dir),
        out_dir = quote_nf(results_dir),
        pheno_batch_size = input$pheno_batch_size,
        window_up = input$window_up,
        window_down = input$window_down,
        gene_location = quote_nf(input$gene_location),
        steps = input$steps,
        chr_column = input$chr_column,
        pos_column = input$pos_column,
        ref_column = input$ref_column,
        alt_column = input$alt_column,
        pval_column = input$pval_column,
        beta_column = input$beta_column,
        se_column = input$se_column,
        af_column = input$af_column,
        n_samples_column = n_samples_column_value,
        pval_neglog10 = input$pval_neglog10,
        ensemblvep_species = quote_nf(input$ensemblvep_species),
        ensemblvep_genome = quote_nf(input$ensemblvep_genome),
        ensemblvep_cache_version = input$ensemblvep_cache_version,
        ensemblvep_cache = quote_nf(input$ensemblvep_cache),
        magma_reference_plink = quote_nf(input$magma_reference_plink)
      )
    )
    
    write_config(
      file.path(configs_dir, "compute.config"),
      list(
        slurm_queue = quote_nf(input$slurm_queue),
        global_maxForks = input$global_maxForks,
        normalize_cpus = input$normalize_cpus,
        normalize_memory = quote_nf(input$normalize_memory),
        vcf_cpus = input$vcf_cpus,
        vcf_memory = quote_nf(input$vcf_memory),
        manhattan_qq_cpus = input$manhattan_qq_cpus,
        manhattan_qq_memory = quote_nf(input$manhattan_qq_memory),
        chrom_bgz_maxForks = input$chrom_bgz_maxForks,
        chrom_bgz_memory = quote_nf(input$chrom_bgz_memory),
        chrom_bgz_cpus = input$chrom_bgz_cpus,
        magma_cpus = input$magma_cpus,
        magma_memory = quote_nf(input$magma_memory),
        magma_input_cpus = input$magma_input_cpus,
        magma_input_memory = quote_nf(input$magma_input_memory)
      )
    )
    
    write_config(
      file.path(configs_dir, "base.config"),
      list(
        manhattan_num_unbinned = input$manhattan_num_unbinned,
        manhattan_peak_max_count = input$manhattan_peak_max_count,
        manhattan_peak_pval_threshold = input$manhattan_peak_pval_threshold,
        manhattan_peak_sprawl_dist = input$manhattan_peak_sprawl_dist,
        top_hits_pval_cutoff = input$top_hits_pval_cutoff,
        top_hits_max_limit = input$top_hits_max_limit,
        ensemblvep_distance_up = input$ensemblvep_distance_up,
        ensemblvep_distance_down = input$ensemblvep_distance_down
      )
    )
    
    run_script <- file.path(job_dir, "run_nf_pipeline.sh")

    java_home <- trimws(input$java_home)
    nextflow_path <- trimws(input$nextflow_path)
    if (!nzchar(java_home) || !nzchar(nextflow_path)) {
      stop("Specify both Java home and Nextflow executable paths.")
    }
    if (grepl("\n", java_home, fixed = TRUE) || grepl("\r", java_home, fixed = TRUE) ||
        grepl("\n", nextflow_path, fixed = TRUE) || grepl("\r", nextflow_path, fixed = TRUE)) {
      stop("Software paths cannot contain line breaks.")
    }

    # nextflow.config already loads JOB_DIR/configs via params.job_dir.
    # Do not write configuration files into the shared pipeline repository.

    script_lines <- c(
      "#!/bin/bash",
      "#SBATCH --job-name=nf_pipeline",
      "#SBATCH --mem=100GB",
      paste0("#SBATCH --partition=", input$slurm_queue),
      paste0("#SBATCH --output=", file.path(logs_dir, "nf_pipeline_%j.out")),
      paste0("#SBATCH --error=", file.path(logs_dir, "nf_pipeline_%j.err")),
      "",
      "set -euo pipefail",
      paste0("export NXF_JAVA_HOME=", shQuote(java_home, type = "sh")),
      paste0("NEXTFLOW_BIN=", shQuote(nextflow_path, type = "sh")),
      paste0("PIPELINE_DIR=", shQuote(pipeline_dir, type = "sh")),
      paste0("JOB_DIR=", shQuote(job_dir, type = "sh")),
      paste0("OUT_DIR=", shQuote(results_dir, type = "sh")),
      'if [ ! -x "$NXF_JAVA_HOME/bin/java" ]; then echo "[ERROR] Invalid Java home" >&2; exit 1; fi',
      'if [ ! -x "$NEXTFLOW_BIN" ]; then echo "[ERROR] Invalid Nextflow executable" >&2; exit 1; fi',
      '"$NXF_JAVA_HOME/bin/java" -version',
      '"$NEXTFLOW_BIN" -version',
      'if ! command -v conda >/dev/null 2>&1; then echo "[ERROR] Conda unavailable on the SLURM node" >&2; exit 1; fi',
      'cd "$JOB_DIR"',
      'echo "[INFO] Starting GNExT (automatic Conda setup)"',
      '"$NEXTFLOW_BIN" run "$PIPELINE_DIR/main.nf" -profile slurm,conda --job_dir "$JOB_DIR" > >(tee "$JOB_DIR/logs/nextflow.log") 2> >(tee -a "$JOB_DIR/logs/nextflow.log" >&2)',
      'echo "[INFO] GNExT completed successfully"',
      '# Materialize output symlinks only after a successful run.',
      'if [ -d "$OUT_DIR" ]; then',
      '  while IFS= read -r -d "" link; do',
      '    target=$(readlink -f "$link")',
      '    if [ -f "$target" ]; then cp --remove-destination "$target" "$link"; fi',
      '  done < <(find "$OUT_DIR" -type l -print0)',
      'fi'
    )

    writeLines(script_lines, run_script)
    Sys.chmod(run_script, mode = "0755")
    
    run_script
  }
  
  observeEvent(input$create_job_files, {
    tryCatch({
      run_script <- create_job_files()
      
      output$run_status <- renderText({
        paste(
          "Job files created successfully.",
          paste0("Run script: ", run_script),
          sep = "\n"
        )
      })
    }, error = function(e) {
      output$run_status <- renderText({
        paste("Error while creating job files:", e$message)
      })
    })
  })
  
  observeEvent(input$run_pipeline, {
    tryCatch({
      job_dir <- normalizePath(input$job_dir, mustWork = TRUE)
      run_script <- file.path(job_dir, "run_nf_pipeline.sh")
      
      if (!file.exists(run_script)) {
        stop("run_nf_pipeline.sh does not exist. Please create config files first.")
      }
      
      res <- system2(
        "sbatch",
        args = shQuote(run_script),
        stdout = TRUE,
        stderr = TRUE
      )
      
      status <- attr(res, "status")
      if (!is.null(status) && status != 0) stop(paste(res, collapse = "\n"))

      output$run_status <- renderText({
        paste(
          "Pipeline submitted with sbatch.",
          paste0("Run script: ", run_script),
          paste(res, collapse = "\n"),
          sep = "\n"
        )
      })
    }, error = function(e) {
      output$run_status <- renderText({
        paste("Error while submitting pipeline:", e$message)
      })
    })
  })
  
  quote_env <- function(x) {
    x <- as.character(x)
    x <- gsub('"', '\\"', x)
    paste0('"', x, '"')
  }
  
  generate_random_key <- function(n = 48) {
    chars <- c(letters, LETTERS, 0:9)
    paste0(sample(chars, n, replace = TRUE), collapse = "")
  }
  
  observeEvent(input$generate_typesense_key, {
    updateTextInput(
      session,
      "platform_VITE_TYPESENSE_KEY",
      value = generate_random_key()
    )
  })
  
  create_platform_files <- function() {

    env_dir <- normalizePath(input$platform_env_dir, mustWork = FALSE)
    dir.create(env_dir, recursive = TRUE, showWarnings = FALSE)

    env_file <- file.path(env_dir, ".env")

    # ----------------------
    # Create .env file
    # ----------------------
    lines <- c(
      "# ============================================",
      "# GNExT Platform Environment Configuration",
      "# ============================================",
      "",
      "# Study Identifier for Deployment",
      paste0("STUDY_ACRONYM=", input$platform_STUDY_ACRONYM),
      "",
      "# Study Name and Genome Build",
      paste0("VITE_STUDY_NAME=", quote_env(input$platform_VITE_STUDY_NAME)),
      paste0("VITE_GENOME_BUILD=", input$platform_VITE_GENOME_BUILD),
      paste0("VITE_HG_BUILD_NUMBER=", input$platform_VITE_HG_BUILD_NUMBER),
      "",
      "# Study-Specific Data Paths",
      paste0("PHENO_FILE=", input$platform_PHENO_FILE),
      paste0("NF_DATA_DIR=", input$platform_NF_DATA_DIR),
      "",
      "# Citation Information",
      paste0("VITE_STUDY_BIBTEX_CITATION=", quote_env(input$platform_VITE_STUDY_BIBTEX_CITATION)),
      paste0("VITE_STUDY_PLAIN_CITATION=", quote_env(input$platform_VITE_STUDY_PLAIN_CITATION)),
      paste0("VITE_STUDY_CITATION_DOI_LINK=", quote_env(input$platform_VITE_STUDY_CITATION_DOI_LINK)),
      "",
      "# Example Data",
      paste0("VITE_TRAIT_EXAMPLE=", quote_env(input$platform_VITE_TRAIT_EXAMPLE)),
      paste0("VITE_VARIANT_EXAMPLE=", quote_env(input$platform_VITE_VARIANT_EXAMPLE)),
      paste0("VITE_GENE_EXAMPLE=", quote_env(input$platform_VITE_GENE_EXAMPLE)),
      "",
      "# Feature Configuration",
      paste0("VITE_MAGMA_SHOW=", input$platform_VITE_MAGMA_SHOW),
      paste0("VITE_GENE_ID_SPACE=", quote_env(input$platform_VITE_GENE_ID_SPACE)),
      paste0("VITE_TRAIT_EXTERNAL_REF_URL=", quote_env(input$platform_VITE_TRAIT_EXTERNAL_REF_URL)),
      "",
      "# MAGMA Configuration",
      paste0("MAGMA_REF_POPULATION=", quote_env(input$platform_MAGMA_REF_POPULATION)),
      paste0("MAGMA_REF_GENE_LOCATION=", quote_env(input$platform_MAGMA_REF_GENE_LOCATION)),
      "",
      "# Typesense Configuration",
      paste0("VITE_TYPESENSE_KEY=", input$platform_VITE_TYPESENSE_KEY),
      paste0("VITE_TYPESENSE_PORT=", input$platform_VITE_TYPESENSE_PORT),
      paste0("TYPESENSE_VOLUME_DIR=", input$platform_TYPESENSE_VOLUME_DIR),
      paste0("FORCE_TYPESENSE_RESET=", input$platform_FORCE_TYPESENSE_RESET),
      "",
      "# UI Theming",
      paste0("VITE_COLOR_PRIMARY=", quote_env(input$platform_VITE_COLOR_PRIMARY)),
      paste0("VITE_COLOR_PRIMARY_DARK=", quote_env(input$platform_VITE_COLOR_PRIMARY_DARK)),
      "",
      "# Port Configuration",
      paste0("VITE_BACKEND_PORT=", input$platform_VITE_BACKEND_PORT),
      paste0("VITE_FRONTEND_PORT=", input$platform_VITE_FRONTEND_PORT),
      "",
      "# Processing Configuration",
      paste0("BATCH_SIZE=", input$platform_BATCH_SIZE)
    )

    writeLines(lines, env_file)

    # ----------------------
    # Create Docker launch script
    # ----------------------
    platform_repo_dir <- normalizePath(input$platform_repo_dir, mustWork = TRUE)

    study_acronym_safe <- gsub("[^A-Za-z0-9_-]", "_", input$platform_STUDY_ACRONYM)

    project_name <- paste0("gnext_", study_acronym_safe)

    env_file_in_repo <- paste0(".env.", study_acronym_safe)

    script_file <- file.path(env_dir, "run_gnext_platform.sh")

  script_lines <- c(
    "#!/bin/bash",
    "set -euo pipefail",
    "",
    paste0('PLATFORM_DIR="', platform_repo_dir, '"'),
    paste0('SOURCE_ENV_FILE="', env_file, '"'),
    paste0('ENV_FILE="', env_file_in_repo, '"'),
    paste0('COMPOSE_PROJECT_NAME="', project_name, '"'),
    "",
    'cd "$PLATFORM_DIR"',
    "",
    'cp "$SOURCE_ENV_FILE" "$ENV_FILE"',
    "",
    'ls -l "$ENV_FILE"',
    "",
    'ENV_FILE="$ENV_FILE" COMPOSE_PROJECT_NAME="$COMPOSE_PROJECT_NAME" \\',
    'docker compose --env-file "$ENV_FILE" build --no-cache',
    "",
    'ENV_FILE="$ENV_FILE" COMPOSE_PROJECT_NAME="$COMPOSE_PROJECT_NAME" \\',
    'docker compose --env-file "$ENV_FILE" up -d',
    "",
    'echo "[INFO] Waiting for Typesense initialization..."',
    "",
    "# timeout: 600s = 10 min",
    "MAX_WAIT=600",
    "WAITED=0",
    "",
    'while true; do',
    '  if ENV_FILE="$ENV_FILE" COMPOSE_PROJECT_NAME="$COMPOSE_PROJECT_NAME" \\',
    '    docker compose --env-file "$ENV_FILE" logs gnext-backend 2>&1 | grep -q "Starting gunicorn"; then',
    '    echo "[OK] GNExT platform is ready!"',
    '    break',
    '  fi',
    "",
    '  if [ $WAITED -ge $MAX_WAIT ]; then',
    '    echo "[WARN] Timeout reached. Restarting backend and frontend..."',
    "",
    '    ENV_FILE="$ENV_FILE" COMPOSE_PROJECT_NAME="$COMPOSE_PROJECT_NAME" \\',
    '    docker compose --env-file "$ENV_FILE" up -d gnext-backend gnext-frontend',
    "",
    '    echo "[INFO] Restart triggered. Waiting again..."',
    '    WAITED=0',
    '  fi',
    "",
    '  echo "[INFO] Still importing... (${WAITED}s)"',
    '  sleep 30',
    '  WAITED=$((WAITED + 30))',
    'done'
  )

    writeLines(script_lines, script_file)
    Sys.chmod(script_file, "0755")

    list(
      env_file = env_file,
      script_file = script_file,
      env_file_in_repo = file.path(platform_repo_dir, env_file_in_repo),
      project_name = project_name
    )
  }
  
  
  observeEvent(input$create_env_file, {
    tryCatch({
      files <- create_platform_files()
      
      output$platform_status <- renderText({
        paste(
          ".env file and Docker script created successfully.",
          paste0(".env file: ", files$env_file),
          paste0("Docker script: ", files$script_file),
          paste0("Docker Compose project name: ", files$project_name),
          "",
          "Run with:",
          paste0("bash ", files$script_file),
          sep = "\n"
        )
      })
    }, error = function(e) {
      output$platform_status <- renderText({
        paste("Error while creating platform files:", e$message)
      })
    })
  })
  
  
  
}

shinyApp(ui, server)
