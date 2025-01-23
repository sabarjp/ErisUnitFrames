import json
import re

def normalize_description(description, synonym_map):
    """
    Normalize descriptions by replacing synonyms with standard terms.
    """
    # Convert the description to lowercase
    description = description.lower()

    # Process each standard term and its variants in the synonym map
    for standard, variants in synonym_map.items():
        for variant in variants:
            description = re.sub(rf"\b{re.escape(variant)}\b", standard, description)

    # Handle special phrases like "all attributes down", "reduces all attributes", "absorbs all attributes", "all attributes set to 1"
    if any(phrase in description for phrase in ["all attributes down", "reduces all attributes", "absorbs all attributes", "all attributes set to 1"]):
        attributes = "str down, dex down, agi down, int down, mnd down, chr down, vit down"

        description = description.replace("all attributes down", attributes)
        description = description.replace("reduces all attributes", attributes)
        description = description.replace("absorbs all attributes", attributes)
        description = description.replace("all attributes set to 1", attributes)

    #print(description)
    return description


def process_monster_abilities(monster_data, abilities_data, buffs_data):
    """
    Processes monster abilities and maps them to Lua-compatible data.
    """
    output_lines = ["return {"]

    # Define synonyms for normalization
    synonym_map = {
        "blindness": ["blind", "blinded", "blindness"],
        # ... other synonyms
    }

    # Duration lookup table (ability name -> duration in seconds)
    duration_lookup = {
        "dia": 60,
        "bio": 60,
        "hasted": 180,
        "slowed": 180,
        "blinded": 180,
        "refreshed": 150,
        "poisoned": 90,
        "sleep": 60,
        "bound": 60,
        "stun": 10,
        # Add more specific cases here
    }

    # Sort buffs by the length of their "en" and "enl" fields, in descending order
    sorted_buffs = sorted(
        buffs_data.items(),
        key=lambda item: max(len(item[1]["en"]), len(item[1]["enl"])),
        reverse=True
    )

    for family, abilities in monster_data.items():
        output_lines.append(f"  -- {family.lower()} family")

        for ability_name, details in abilities.items():
            ability_en = details["ability"]
            description = normalize_description(details.get("description", ""), synonym_map)

            tokens = re.split(r'\s+and\s+|\s+or\s+|,\s*', description)
            tokens = [token.strip() for token in tokens if token.strip()]

            matched_ability_ids = [
                int(id_)
                for id_, ability in abilities_data.items()
                if ability["en"].lower() == ability_en.lower()
            ]

            matched_status_ids = []
            matched_tokens = set()

            for token in tokens:
                if token in matched_tokens:
                    continue

                for id_, buff in sorted_buffs:
                    if re.search(rf'\b{re.escape(buff["en"].lower())}\b', token) or re.search(rf'\b{re.escape(buff["enl"].lower())}\b', token):
                        matched_status_ids.append(int(id_))
                        matched_tokens.add(token)
                        break


            # Determine the duration based on the matched buffs
            ability_duration = 120  # Default duration
            for id_ in matched_status_ids:
                buff_name1 = buffs_data[str(id_)]["en"].lower()
                buff_name2 = buffs_data[str(id_)]["enl"].lower()
                for key in duration_lookup:
                    if key in buff_name1 or key in buff_name2:  # Partial match for buff name
                        ability_duration = duration_lookup[key]
                        break

            for ability_id in matched_ability_ids:
                if matched_status_ids:
                    status_ids_str = ", ".join(map(str, matched_status_ids))
                    comment = ", ".join(buffs_data[str(id_)]["en"] for id_ in matched_status_ids)
                    lua_line = (
                        f"  [{ability_id}] = {{ id = {ability_id}, en = \"{ability_en}\", "
                        f"status = {{ {status_ids_str} }}, duration = {ability_duration} }}, -- {comment}"
                    )
                    output_lines.append(lua_line)

    output_lines.append("}")
    return "\n".join(output_lines)


# Example usage
with open("raw_monster_data.json", "r", encoding="utf-8") as file:
    raw_monster_data = json.load(file)

with open("monster_abilities.json", "r", encoding="utf-8") as file:
    monster_abilities = json.load(file)

with open("buffs.json", "r", encoding="utf-8") as file:
    buffs = json.load(file)

lua_output = process_monster_abilities(raw_monster_data, monster_abilities, buffs)

with open("processed_monster_abilities.lua", "w", encoding="utf-8") as file:
    file.write(lua_output)
