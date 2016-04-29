from random import randint

from app.userprofile.models import UserProfile, UserGroup
from app.userprofile.views.users import generate_user

def create_hidden_group_for_course(course):
    print("CREATING HIDDEN GROUP")
    group = UserGroup()
    group.name = "custom_group-%s-%s" % (course.name, randint(0,1000000)) 
    group.is_hidden = True
    group.save()
    print("CREATED HIDDEN GROUP")
    return group
    
def generate_user_for_course(course, username_prefix=None):
    print("GENERATE USER")
    username_prefix = username_prefix or course.name
    print("GENERATE USER")
    group = create_hidden_group_for_course(course)
    print("GENERATE USER")
    user = generate_user(username_prefix)
    print("GENERATE USER")
    user.groups.add(group)
    print("GENERATE USER")
    course.groups.add(group)
    print("GENERATE USER")
    
def generate_users_for_course(course, prefix, amount):
    for i in range(0,amount):
        generate_user_for_course(course, prefix)
    