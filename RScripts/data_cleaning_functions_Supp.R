# functions used for data cleaning####

id_unknowns <- function(dat, tag_col) {
  
  # give unique numbers to blank tags
  # note: these are 7 digit numbers, so they are longer than any other tag type
  # note: tag_col is the column number for tags (i.e., 18)
  
  unk = 1000000
  
  for (irow in 1:nrow(dat)) {
    
    tag = dat[irow, tag_col]
    unk = unk + 1
    
    if (rapportools::is.empty(tag)) {
      dat[irow, tag_col] = unk
    } else if (tag == '0') {
      dat[irow, tag_col] = unk
    }
  }
  
  return(dat)
  
}

starred_tags <- function(dat, tags, spp_col, tag_col) {
  
  # check for *, which indicates a new tag
  # tags with multiple rows are sorted by species, then checked for *
  # if a * exists, then each time it is given a new unique tag, that ends with "s" for "star" (from note2 column)
  # find tags that are 6 characters but are toe tags, not PIT tags
  
  tags_6 <-
    dat[nchar(dat$tag) >= 6, ] # tags with 6 or more characters
  no_PITtags <- tags_6 %>%
    filter(stringr::str_detect(tag, "[HIMNOPRSTUX]")) %>% # have characters not found in PIT tags
    filter(grepl('\\d{4}\\w{2}', tag)) %>% # have 4 digits followed by 2 characters (unlikely to be a PIT tag)
    select(tag)
  
  numcount = 1
  
  for (t in 1:length(tags)) {
    # only run on ear and toe tags, pit tags are very unlikely to be duplicated
    
    if (nchar(tags[t]) < 6 | tags[t] %in% no_PITtags$tag) {
      tmp <- which(dat$tag == tags[t])
      
      # if indiv was captured multiple times
      if (nrow(dat[tmp, ]) > 1) {
        # check num species recorded. If more than one, does data look OK if separated on species?
        spp_list = unique(dat[tmp, spp_col]) # num of species with that tag
        
        for (sp in 1:length(spp_list)) {
          tmp2 = which(dat$tag == tags[t] & dat$species == spp_list[sp])
          
          isnew = as.vector(dat[tmp2, ]$note2)
          
          if ("*" %in% isnew) {
            rowbreaks = which(isnew == "*", arr.ind = TRUE) # find rows where * indicates a new tag
            
            for (r in 1:length(rowbreaks)) {
              if (r == 1) {
                # GIVE an ID up to the first *
                newtag = paste(tags[t], numcount, "s", sep = "") #make a new tag to keep separate
                dat[tmp2, ][1:rowbreaks[r] - 1, tag_col] = newtag # dataframe with rows before the next star
                numcount = numcount + 1
                
                # AND an ID to everything after the first * (the loop should take care of the next set and so on)
                newtag = paste(tags[t], numcount, "s", sep = "") # make a new tag to keep separate
                dat[tmp2, ][rowbreaks[r]:nrow(dat[tmp2, ]), tag_col] = newtag # identifies this as different
                numcount = numcount + 1
              } else if (r > 1) {
                # GIVE an ID to everything after the next *
                newtag = paste(tags[t], numcount, "s", sep = "") # make a new tag to keep separate
                dat[tmp2, ][rowbreaks[r]:nrow(dat[tmp2, ]), tag_col] = newtag
                numcount = numcount + 1
              }
            }
          }
        }
      }
    }
  }
  
  return(dat)
  
}

is_dead <- function(dat, tags, spp_col, tag_col) {
  
  # checks note5 for "D", which indicated a dead rat.
  # by definition, all captures with the same tagID afterwards, must be a different individual
  # assign these captures with a new tag ID that ends with 'm' for 'mortality.
  
  numcount = 1
  
  for (t in 1:length(tags)) {
    tmp <- which(dat$tag == tags[t])
    
    # if indiv was captured multiple times
    if (nrow(dat[tmp, ]) > 1) {
      # check num species recorded. If more than one, does data look OK if separated on species?
      spp_list = unique(dat[tmp, spp_col])
      
      for (sp in 1:length(spp_list)) {
        tmp2 = which(dat$tag == tags[t] & dat$species == spp_list[sp])
        
        isdead = as.vector(dat[tmp2, ]$note5)
        
        if ("D" %in% isdead) {
          rowbreaks = which(isdead == "D", arr.ind = TRUE) # find rows where D indicates a dead individuals
          endrow = nrow(dat[tmp2, ])                        # number of rows w/ that tag and species code
          
          for (r in 1:length(rowbreaks)) {
            # length(rowbreaks) = number times D recorded
            if (r == 1) {
              # first row break for that tag
              if (rowbreaks[r] == endrow) {
                # only one time where the tag and species combo is recorded
                
                # GIVE an ID up to the first *
                newtag = paste(tags[t], numcount, "m", sep = "") # make a new tag to keep separate
                numrows = nrow(dat[tmp2, ][1:rowbreaks[r], ])
                newtagvector = as.vector(rep(newtag, numrows))
                dat[tmp2, ][1:rowbreaks[r], tag_col] = newtag
                numcount = numcount + 1
                
              } else {
                # if number of rows w/ combo is higher than 1
                
                # GIVE an ID up to the first *
                newtag = paste(tags[t], numcount, "m", sep = "") # make a new tag to keep separate
                numrows = nrow(dat[tmp2, ][1:rowbreaks[r], ])
                newtagvector = as.vector(rep(newtag, numrows))
                dat[tmp2, ][1:rowbreaks[r], tag_col] = newtag
                numcount = numcount + 1
                
                # AND an ID to everything after the first "D" (the loop should take care of the next set and so on)
                startrow = rowbreaks[r] + 1
                newtag = paste(tags[t], numcount, "m", sep = "") # make a new tag to keep separate
                numrows = nrow(dat[tmp2, ][(startrow:endrow), ])
                newtagvector = as.vector(rep(newtag, numrows))
                dat[tmp2, ][(startrow:endrow), tag_col] = newtag
                numcount = numcount + 1
                
              }
            } else if (r > 1) {
              # if this is not the first time a D is encountered for this tag
              if (rowbreaks[r] == endrow) {
                break
              } else {
                # GIVE an ID to everything after the next "D"
                startrow = rowbreaks[r] + 1
                newtag = paste(tags[t], numcount, "m", sep = "") # make a new tag to keep separate
                numrows = nrow(dat[tmp2, ][(startrow:endrow), ])
                newtagvector = as.vector(rep(newtag, numrows))
                dat[tmp2, ][(startrow:endrow), tag_col] = newtag
                numcount = numcount + 1
                
              }
            }
          }
        }
      }
    }
  }
  
  return(dat)
  
}



is_duplicate_tag <- function(dat, tags, spp_col, tag_col) {
  
  # check the min to max year for a given tag.
  # If > 4, considered suspicious
  # If multiple species, considered suspicious
  # If adequately resolved, given a new unique tag number, that ends with d for "duplicate"
  # returns a list with 2 elements [1] altered data, [2] flagged data
  
  numcount = 100
  flagged_rats = data.frame("tag" = 1,
                            "reason" = 1,
                            "occurrences" = 1)
  outcount = 0
  
  # find tags that are 6 characters but are toe tags, not PIT tags
  tags_6 <-
    dat[nchar(dat$tag) >= 6, ] # tags with 6 or more characters
  no_PITtags <- tags_6 %>%
    filter(stringr::str_detect(tag, "[HIMNOPRSTUX]")) %>% # have characters not found in PIT tags
    filter(grepl('\\d{4}\\w{2}', tag)) %>% # have 4 digits followed by 2 characters (unlikely to be a PIT tag)
    select(tag)
  
  all_tags <- c(tags, as.list(unlist(no_PITtags)))
  unique_tags <- unique(all_tags)
  
  for (t in 1:length(unique_tags)) {
    # only run on ear and toe tags, pit tags are very unlikely to be duplicated
    if (nchar(tags[t]) < 6 | tags[t] %in% no_PITtags$tag) {
      tmp <- which(dat$tag == tags[t])
      
      # if indiv was captured multiple times
      if (nrow(dat[tmp, ]) > 1) {
        # more than 3 years between recaptures? Rodents are short-lived.
        if (max(dat[tmp, 1]) - min(dat[tmp, 1]) >= 3) {
          # check num species recorded. If more than one, does data look OK if separated on species?
          spp_list = unique(dat[tmp, spp_col])
          
          for (sp in 1:length(spp_list)) {
            tmp2 = which(dat$tag == tags[t] & dat$species == spp_list[sp])
            
            # Check for duplicate tags in the same period and same species.
            # This likely indicates multiple individuals with the same tag.
            if (anyDuplicated(dat[tmp2, ]) > 0) {
              outcount = outcount + 1
              flagged_rats[outcount, ] <-
                c(tags[t], "sameprd", nrow(dat[tmp, ]))
            }
            
            # Dipodomys are long-lived. Raise the threshold for these indivs
            if (spp_list[sp] %in% list("DO", "DM", "DS")) {
              if (max(dat[tmp2, 1]) - min(dat[tmp2, 1]) < 5) {
                newtag = paste(tags[t], numcount, "d", sep = "") # make a new tag to keep separate
                dat[tmp2, tag_col] = newtag
                numcount = numcount + 1
              } else {
                outcount = outcount + 1
                flagged_rats[outcount, ] <-
                  c(tags[t], "year", nrow(dat[tmp, ]))
              }
            }
            
            # Other genera are very short-lived. Flag data if same individual appears to occur >= 3 years.
            else {
              if (max(dat[tmp2, 1]) - min(dat[tmp2, 1]) < 3) {
                newtag = paste(tags[t], numcount, "d", sep = "") # make a new tag to keep separate
                dat[tmp2, tag_col] = newtag
                numcount = numcount + 1
              } else {
                outcount = outcount + 1
                flagged_rats[outcount, ] <-
                  c(tags[t], "year", nrow(dat[tmp, ]))
              }
            }
          }
        }
      }
    }
  }
  
  info = list(data = dat, bad = flagged_rats)
  return (info)
  
}


same_period <- function(dat, tags){
  
  # multiple individuals with same tag captured in same period = questionable
  
  flagged_rats = data.frame("tag"=1, "reason"=1, "occurrences"=1)
  outcount = 0
  
  for (t in 1:length(tags)){
    tmp <- which(dat$tag == tags[t])
    
    if (nrow(dat[tmp,]) > 1){
      periods = unique(dat[tmp,]$period)
      for (p in 1:length(periods)){
        ptmp <- which(dat$tag == tags[t] & dat$period == periods[p])
        if (nrow(dat[ptmp,]) > 1){
          outcount = outcount + 1
          flagged_rats[outcount,] <- c(tags[t], "sameprd", nrow(dat[ptmp,]))
          break
        }
      }
    }
  }
  
  return (flagged_rats)
  
}

find_bad_data2 <- function(dat, tags, sex_col, spp_col) {
  
  # used in 'subsetDat' function
  # check for consistent sex and species, outputs flagged tags to check, 
  #     or to remove from study
  
  flagged_rats = data.frame("tag" = 1,
                            "reason" = 1,
                            "occurrences" = 1)
  outcount = 0
  
  for (t in 1:length(tags)) {
    tmp <- which(dat$tag == tags[t])
    
    if (nrow(dat[tmp, ]) > 1) {
      # if indiv was captured multiple times
      spp_list = dat[tmp, spp_col]
      spp = spp_list[1]
      for (s in 2:length(spp_list)) {
        # check for consistent species
        if (spp_list[s] != spp) {
          outcount = outcount + 1
          flagged_rats[outcount, ] <-
            c(tags[t], "spp", nrow(dat[tmp, ]))
          break
        }
      }
    }
  }
  
  return(flagged_rats)
  
}

subsetDat <- function(dataset){
  
  # function to subset out proper data 
  # will find bad data, then delete it from the dataset
  
  tags = as.character(unique(dataset$tag)) # get list of unique tags
  flags = find_bad_data2(dataset, tags, 10, 9)   # list of flagged data
  
  # first, mark all uncertain or unmarked sex as "U" for unknown
  #     and get rid of other weird typos in sex column
  dataset[which(dataset$sex %in% c("", "P", "Z")), 10] = "U" 
  
  # get rid of results where we don't know the species for sure
  badspptags = unique(flags[which(flags$reason == "spp"), 1])    
  dataset = dataset[-which(dataset$tag %in% badspptags),] 
  # delete rows where species is unsure
  
  return (dataset)
  
}
