class ResumeData {
  // Step 1: Personal Info
  String fullName = "";
  String email = "";
  String phone = "";
  String location = "";
  String professionalSummary = "";

  // Step 2: Education
  List<EducationItem> education = [EducationItem()];

  // Step 3: Experience
  List<ExperienceItem> experience = [ExperienceItem()];

  // Step 4: Skills & Projects
  List<String> skills = [""];
  List<ProjectItem> projects = [ProjectItem()];

  ResumeData();

  ResumeData.clone(ResumeData other) {
    fullName = other.fullName;
    email = other.email;
    phone = other.phone;
    location = other.location;
    professionalSummary = other.professionalSummary;
    education = other.education.map((e) => EducationItem.clone(e)).toList();
    experience = other.experience.map((e) => ExperienceItem.clone(e)).toList();
    skills = List.from(other.skills);
    projects = other.projects.map((e) => ProjectItem.clone(e)).toList();
  }
}

class EducationItem {
  String institution = "";
  String degree = "";
  String duration = "";
  EducationItem();
  EducationItem.clone(EducationItem other) {
    institution = other.institution;
    degree = other.degree;
    duration = other.duration;
  }
}

class ExperienceItem {
  String company = "";
  String position = "";
  String duration = "";
  String responsibilities = "";
  ExperienceItem();
  ExperienceItem.clone(ExperienceItem other) {
    company = other.company;
    position = other.position;
    duration = other.duration;
    responsibilities = other.responsibilities;
  }
}

class ProjectItem {
  String title = "";
  String link = "";
  String description = "";
  ProjectItem();
  ProjectItem.clone(ProjectItem other) {
    title = other.title;
    link = other.link;
    description = other.description;
  }
}
