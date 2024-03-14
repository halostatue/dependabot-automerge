BEGIN {
  version_pattern = base_pattern
  sub(/%v/, version, version_pattern)
  match_pattern = sprintf("%s %s", prefix, version_pattern)

  collect = 0
  skip = 0
  found = 0

  if (trace == 1) {
    print "version:", version
    print "prefix:", prefix
    print "base_pattern:", base_pattern
    print "version pattern:", version_pattern
    print "match pattern:", match_pattern
  }
}

index($0, match_pattern) == 1 {
  if (!found) {
    collect = 1
    skip = 1
    found = 1
  } else {
    collect = 0
  }
  next
}

collect && $0 ~ /^$/ && skip {
  next
}

collect {
  if ($0 ~ /^## /) {
    collect = 0
  } else {
    skip = 0
    print
  }
}
